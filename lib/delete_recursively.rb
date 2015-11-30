#
# DeleteRecursively
#
# Adds a new dependent: option to ActiveRecord associations.
#
module DeleteRecursively
  NEW_DEPENDENT_OPTION = :delete_recursively

  # override ::valid_dependent_options to make the new
  # dependent option available to association builders
  module OptionPermission
    def valid_dependent_options
      super + [NEW_DEPENDENT_OPTION]
    end
  end

  # override #handle_dependency to apply the new option if set
  module DependencyHandling
    def handle_dependency
      super unless DeleteRecursively.enabled_for?(self)
      # Pass true because #handle_dependency is triggered by destroy
      # callbacks, and thus the owner is already being deleted.
      DeleteRecursively.delete_recursively(owner.class, owner.id, true)
    end
  end

  def self.enabled_for?(association)
    association.options[:dependent] == NEW_DEPENDENT_OPTION
  end

  def self.delete_recursively(record_class, record_ids, only_dependents = false)
    # delete all passed records
    record_class.delete(record_ids) unless only_dependents

    # delete all records with a dependency on the passed records
    record_class.reflect_on_all_associations.each do |assoc|
      next unless enabled_for?(assoc)
      dependent_class = assoc.klass
      dependent_ids = dependent_ids(record_class, record_ids, assoc)
      delete_recursively(dependent_class, dependent_ids)
    end
  end

  def self.dependent_ids(record_class, record_ids, assoc)
    if assoc.belongs_to?
      records_arel = record_class.where(record_class.primary_key => record_ids)
      records_arel.pluck(assoc.association_foreign_key).compact
    else
      custom_foreign_key = assoc.options[:foreign_key]
      foreign_key = custom_foreign_key || record_class.to_s.foreign_key
      assoc.klass.where(foreign_key => record_ids).ids
    end
  end

  def self.all(record_class)
    record_class.delete_all
    record_class.reflect_on_all_associations.each do |assoc|
      all(assoc.klass) if enabled_for?(assoc)
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
