# frozen_string_literal: true

#
# DeleteRecursively
#
# Adds a new dependent: option to ActiveRecord associations.
#
module DeleteRecursively
  NEW_DEPENDENT_OPTION = :delete_recursively

  require_relative File.join('delete_recursively', 'active_record_extensions')
  require_relative File.join('delete_recursively', 'associated_class_finder')
  require_relative File.join('delete_recursively', 'dependent_id_finder')
  require_relative File.join('delete_recursively', 'railtie') if defined?(::Rails::Railtie)
  require_relative File.join('delete_recursively', 'version')

  class << self
    def delete_recursively(reflection, _legacy_arg, owner_ids, seen: [], force: false)
      owner_ids = Array(owner_ids)
      return if owner_ids.empty?

      # Dependent deletion can be bi-directional, so we need to avoid a loop.
      # Note, however, that an association could be reached multiple times, from
      # different starting points within the association tree, and having
      # different owner_ids. In this case, we do need to go through it again.
      recursion_identifier = [reflection, owner_ids]
      return if seen.include?(recursion_identifier)

      seen << recursion_identifier

      AssociatedClassFinder.call(reflection).each do |assoc_class|
        record_ids = nil # fetched only when needed for recursion, deletion, or both

        if recurse_on?(reflection)
          record_ids = DependentIdFinder.call(owner_ids, reflection, assoc_class)
          assoc_class.reflect_on_all_associations.each do |subref|
            delete_recursively(subref, nil, record_ids, seen: seen, force: force)
          end
        end

        if dest_method = destructive_method(reflection, force: force)
          record_ids ||= DependentIdFinder.call(owner_ids, reflection, assoc_class)
          assoc_class.send(dest_method, record_ids)
        end
      end
    end

    def delete_records_recursively(record_class, record_ids, force: false)
      record_class.reflect_on_all_associations.each do |ref|
        delete_recursively(ref, nil, record_ids, force: force)
      end
      record_class.delete(record_ids)
    end

    def all(record_class, criteria = {}, seen = [])
      return if seen.include?(record_class)

      seen << record_class

      record_class.reflect_on_all_associations.each do |reflection|
        AssociatedClassFinder.call(reflection).each do |assoc_class|
          if recurse_on?(reflection)
            all(assoc_class, criteria, seen)
          elsif deleting?(reflection)
            delete_with_applicable_criteria(assoc_class, criteria)
          end
        end
      end

      delete_with_applicable_criteria(record_class, criteria)
    end

    def enabled_for?(reflection)
      reflection.options[:dependent] == NEW_DEPENDENT_OPTION
    end

    private

    def delete_with_applicable_criteria(record_class, criteria)
      applicable_criteria = criteria.select do |column_name, _value|
        record_class.column_names.include?(column_name.to_s)
      end
      record_class.where(applicable_criteria).delete_all
    end

    def recurse_on?(reflection)
      enabled_for?(reflection) || destructive?(reflection)
    end

    def destructive?(reflection)
      %i[destroy destroy_all].include?(reflection.options[:dependent])
    end

    def deleting?(reflection)
      [:delete, :delete_all, NEW_DEPENDENT_OPTION].include?(reflection.options[:dependent])
    end

    def destructive_method(reflection, force: false)
      if deleting?(reflection) || force && destructive?(reflection)
        :delete
      elsif destructive?(reflection)
        :destroy
      end
    end
  end
end
