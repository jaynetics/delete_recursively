# frozen_string_literal: true

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
        DeleteRecursively.delete_recursively(reflection, owner.class, owner.id, force: force)
      end
    end
  end

  class << self
    def delete_recursively(reflection, owner_class, owner_ids, seen: [], force: false)
      # Dependent deletion can be bi-directional, so we need to avoid a loop.
      return if seen.include?(reflection)

      seen << reflection

      associated_classes(reflection).each do |record_class|
        record_ids = nil # fetched only when needed for recursion, deletion, or both

        if recurse_on?(reflection)
          record_ids = dependent_ids(owner_class, owner_ids, reflection, record_class)
          record_class.reflect_on_all_associations.each do |subref|
            delete_recursively(subref, record_class, record_ids, seen: seen, force: force)
          end
        end

        if dest_method = destructive_method(reflection, record_class, record_ids, force: force)
          record_ids ||= dependent_ids(owner_class, owner_ids, reflection, record_class)
          record_class.send(dest_method, record_ids)
        end
      end
    end

    def associated_classes(reflection)
      if reflection.polymorphic?
        # This ignores relatives where the inverse relation is not defined.
        # The alternative to this approach would be to expensively select
        # all distinct values from the *_type column:
        # reflection.active_record.distinct.pluck(reflection.foreign_type)
        ActiveRecord::Base.descendants.select do |klass|
          klass.reflect_on_all_associations
               .any? { |ref| ref.inverse_of == reflection }
        end
      else
        [reflection.klass]
      end
    end

    def delete_records_recursively(record_class, record_ids, force: false)
      record_class.reflect_on_all_associations.each do |ref|
        delete_recursively(ref, record_class, record_ids, force: force)
      end
      record_class.delete(record_ids)
    end

    def destructive_method(reflection, record_class, record_ids, force: false)
      if deleting?(reflection) || force && destructive?(reflection)
        :delete
      elsif destructive?(reflection)
        :destroy
      end
    end

    def recurse_on?(reflection)
      enabled_for?(reflection) || destructive?(reflection)
    end

    def enabled_for?(reflection)
      reflection.options[:dependent] == NEW_DEPENDENT_OPTION
    end

    def destructive?(reflection)
      %i[destroy destroy_all].include?(reflection.options[:dependent])
    end

    def deleting?(reflection)
      [:delete, :delete_all, NEW_DEPENDENT_OPTION].include?(reflection.options[:dependent])
    end

    def dependent_ids(owner_class, owner_ids, reflection, assoc_class = nil)
      if reflection.belongs_to?
        owners = owner_class.where(owner_class.primary_key => owner_ids)
        if reflection.polymorphic?
          owners = owners.where(reflection.foreign_type => assoc_class.to_s)
        end
        owners.pluck(reflection.foreign_key).compact
      elsif reflection.through_reflection
        dependent_ids_with_through_option(owner_class, owner_ids, reflection)
      else # plain `has_many` or `has_one`
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
                        .where(owner_foreign_key => owner_ids)
                        .pluck(dependent_foreign_key)
    end

    def inverse_through_reflection(reflection)
      through_class = reflection.through_reflection.klass
      reflection.klass.reflect_on_all_associations
                .map(&:through_reflection)
                .find { |thr_ref| thr_ref && thr_ref.klass == through_class }
    end

    def foreign_key(owner_class, reflection)
      reflection && reflection.foreign_key || owner_class.to_s.foreign_key
    end

    def all(record_class, criteria = {}, seen = [])
      return if seen.include?(record_class)

      seen << record_class

      record_class.reflect_on_all_associations.each do |reflection|
        associated_classes(reflection).each do |assoc_class|
          if recurse_on?(reflection)
            all(assoc_class, criteria, seen)
          elsif deleting?(reflection)
            delete_with_applicable_criteria(assoc_class, criteria)
          end
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
