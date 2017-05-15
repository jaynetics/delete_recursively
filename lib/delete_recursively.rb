#
# DeleteRecursively
#
# Adds a new dependent: option to ActiveRecord associations.
#
module DeleteRecursively
  require_relative File.join('delete_recursively', 'version')

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

  class << self
    def delete_recursively(reflection, record_ids)
      record_class = reflection.klass
      if recurse_on?(reflection)
        record_class.reflect_on_all_associations.each do |sub_reflection|
          dependent_ids = dependent_ids(record_class, record_ids, sub_reflection)
          delete_recursively(sub_reflection, dependent_ids)
        end
      end
      destroy_or_delete(reflection, record_class, record_ids)
    end

    def destroy_or_delete(reflection, record_class, record_ids)
      if destructive?(reflection)
        record_class.destroy(record_ids)
      elsif enabled_for?(reflection) || deleting?(reflection)
        record_class.delete(record_ids)
      end
    end

    def recurse_on?(reflection)
      enabled_for?(reflection) || destructive?(reflection)
    end

    def enabled_for?(reflection)
      reflection.options[:dependent] == NEW_DEPENDENT_OPTION
    end

    def destructive?(reflection)
      [:destroy, :destroy_all].include?(reflection.options[:dependent])
    end

    def deleting?(reflection)
      [:delete, :delete_all].include?(reflection.options[:dependent])
    end

    def dependent_ids(owner_class, owner_ids, reflection)
      if reflection.belongs_to?
        owners_arel = owner_class.where(owner_class.primary_key => owner_ids)
        owners_arel.pluck(reflection.association_foreign_key).compact
      elsif reflection.through_reflection
        dependent_ids_with_through_option(owner_class, owner_ids, reflection)
      else
        owner_foreign_key = foreign_key(owner_class, reflection)
        reflection.klass.where(owner_foreign_key => owner_ids).ids
      end
    end

    def dependent_ids_with_through_option(owner_class, owner_ids, reflection)
      through_reflection = reflection.through_reflection
      owner_foreign_key = foreign_key(owner_class, through_reflection)

      dependent_class = reflection.klass
      dependent_through_reflection = inverse_through_reflection(reflection)
      dependent_foreign_key =
        foreign_key(dependent_class, dependent_through_reflection)

      through_reflection.klass
        .where(owner_foreign_key => owner_ids).pluck(dependent_foreign_key)
    end

    def inverse_through_reflection(reflection)
      through_class = reflection.through_reflection.klass
      reflection.klass.reflect_on_all_associations
        .map(&:through_reflection)
        .find { |tr| tr && tr.klass == through_class }
    end

    def foreign_key(owner_class, reflection)
      custom_foreign_key = reflection && reflection.options[:foreign_key]
      custom_foreign_key || owner_class.to_s.foreign_key
    end

    def all(record_class, criteria = {})
      record_class.reflect_on_all_associations.each do |reflection|
        if recurse_on?(reflection)
          all(reflection.klass, criteria)
        elsif deleting?(reflection)
          delete_with_applicable_criteria(reflection.klass, criteria)
        end
      end
      delete_with_applicable_criteria(record_class, criteria)
    end

    def delete_with_applicable_criteria(record_class, criteria)
      applicable_criteria = criteria.select do |column_name, _value|
        record_class.column_names.include?(column_name.to_s)
      end
      record_class.where(applicable_criteria).delete_all
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
