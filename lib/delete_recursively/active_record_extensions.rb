# override ::valid_dependent_options to make the new
# dependent option available to Association::Builder classes
module DeleteRecursively::OptionPermission
  def valid_dependent_options
    super + [DeleteRecursively::NEW_DEPENDENT_OPTION]
  end
end

# override Association#handle_dependency to apply the new option if it is set
module DeleteRecursively::DependencyHandling
  def handle_dependency
    if DeleteRecursively.enabled_for?(self)
      delete_dependencies_recursively
    else
      super
    end
  end

  def delete_dependencies_recursively(force: false)
    if reflection.belongs_to?
      # Special case. The owner is already destroyed at this point,
      # so we cannot use the efficient ::dependent_ids lookup. Note that this
      # only happens for a single entry-record on #destroy, though.
      return unless target = load_target

      DeleteRecursively.delete_records_recursively(target.class, target.id, force: force)
    else
      DeleteRecursively.delete_recursively(reflection, nil, owner.id, force: force)
    end
  end
end

require 'active_record'

module ActiveRecord
  module Associations
    %w[BelongsTo HasMany HasOne].each do |assoc_name|
      assoc_builder = Builder.const_get(assoc_name)
      assoc_builder.singleton_class.prepend(DeleteRecursively::OptionPermission)

      assoc_class = const_get("#{assoc_name}Association")
      assoc_class.prepend(DeleteRecursively::DependencyHandling)
    end
  end

  class Base
    def delete_recursively(force: false)
      DeleteRecursively.delete_records_recursively(self.class, id, force: force)
    end
  end

  class Relation
    def delete_all_recursively(force: false)
      DeleteRecursively.delete_records_recursively(klass, ids, force: force)
    end
  end
end
