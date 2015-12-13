#
# DeleteRecursively
#
# Adds a new dependent: option to ActiveRecord associations.
#
module DeleteRecursively
  NEW_DEPENDENT_OPTION = :delete_recursively

  # override ::valid_dependent_options to make the new
  # dependent option available to Association::Builder classes
  module OptionPermission
    def valid_dependent_options
      super + [NEW_DEPENDENT_OPTION]
    end
  end

  # override Association#handle_dependency to apply the new option if it is set
  module DependencyHandling
    def handle_dependency
      return super unless DeleteRecursively.enabled_for?(self)
      if reflection.belongs_to?
        # can't use ::dependent_ids, owner is already destroyed at this point
        ids = load_target ? target.id : []
      else
        ids = DeleteRecursively.dependent_ids(owner.class, owner.id, reflection)
      end
      DeleteRecursively.delete_recursively(reflection, ids)
    end
  end

  def self.delete_recursively(reflection, record_ids)
    record_class = reflection.klass
    record_class.reflect_on_all_associations.each do |sub_reflection|
      next unless recurse_on?(sub_reflection)
      dependent_ids = dependent_ids(record_class, record_ids, sub_reflection)
      delete_recursively(sub_reflection, dependent_ids)
    end
    record_class.delete(record_ids) if enabled_for?(reflection)
    record_class.destroy(record_ids) if destructive?(reflection)
  end

  def self.recurse_on?(reflection)
    enabled_for?(reflection) || destructive?(reflection)
  end

  def self.enabled_for?(reflection)
    reflection.options[:dependent] == NEW_DEPENDENT_OPTION
  end

  def self.destructive?(reflection)
    [:destroy, :destroy_all].include?(reflection.options[:dependent])
  end

  def self.dependent_ids(owner_class, owner_ids, reflection)
    if reflection.belongs_to?
      owners_arel = owner_class.where(owner_class.primary_key => owner_ids)
      owners_arel.pluck(reflection.association_foreign_key).compact
    else
      custom_foreign_key = reflection.options[:foreign_key]
      foreign_key = custom_foreign_key || owner_class.to_s.foreign_key
      reflection.klass.where(foreign_key => owner_ids).ids
    end
  end

  def self.all(record_class, criteria = {})
    record_class.delete_all(criteria)
    record_class.reflect_on_all_associations.each do |reflection|
      all(reflection.klass, criteria) if recurse_on?(reflection)
    end
  end
end

require 'active_record'

%w(BelongsTo HasMany HasOne).each do |assoc_name|
  assoc_builder = ActiveRecord::Associations::Builder.const_get(assoc_name)
  assoc_builder.singleton_class.prepend(DeleteRecursively::OptionPermission)

  assoc_class = ActiveRecord::Associations.const_get("#{assoc_name}Association")
  assoc_class.prepend(DeleteRecursively::DependencyHandling)
end
