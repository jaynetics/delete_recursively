module DeleteRecursively::AssociatedClassFinder
  class << self
    def call(reflection)
      cache[reflection] ||= find_classes(reflection)
    end

    def clear_cache
      cache.clear
    end

    private

    def cache
      @cache ||= {}.tap(&:compare_by_identity)
    end

    def find_classes(reflection)
      result =
        if reflection.polymorphic?
          find_classes_for_polymorphic_reflection(reflection)
        else
          [reflection.klass]
        end.compact

      result.empty? && warn_empty_result(reflection)

      result
    end

    # This ignores relatives where the inverse relation is not defined.
    # The alternative to this approach would be to expensively select
    # all distinct values from the *_type column:
    # reflection.active_record.distinct.pluck(reflection.foreign_type)
    def find_classes_for_polymorphic_reflection(reflection)
      ActiveRecord::Base.descendants.select do |klass|
        klass.reflect_on_all_associations.any? do |other_ref|
          next other_ref.inverse_of == reflection unless other_ref.polymorphic?

          # check if its a bi-directional polymorphic association
          begin
            other_ref.polymorphic_inverse_of(reflection.active_record)
          rescue ActiveRecord::InverseOfAssociationNotFoundError
            next
          end
        end
      end
    end

    def warn_empty_result(reflection)
      warn "#{self} could not find associated class(es) for "\
           "#{reflection.active_record}##{reflection.name}. "\
           "You might need to define the inverse association(s) or, "\
           "if they are already defined, add `as :#{reflection.name}` or "\
           "`inverse_of :#{reflection.name}` to them."
    end
  end
end
