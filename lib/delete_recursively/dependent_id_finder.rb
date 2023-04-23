module DeleteRecursively::DependentIdFinder
  class << self
    def call(owner_ids, reflection, assoc_class)
      owner_class = reflection.active_record

      if reflection.belongs_to?
        owners = owner_class.where(owner_class.primary_key => owner_ids)
        if reflection.polymorphic?
          owners = owners.where(reflection.foreign_type => assoc_class.to_s)
        end
        owners.pluck(reflection.foreign_key).compact
      elsif reflection.through_reflection
        dependent_ids_with_through_option(owner_ids, reflection)
      else # plain `has_many` or `has_one`
        owner_foreign_key = foreign_key(owner_class, reflection)
        reflection.klass.where(owner_foreign_key => owner_ids).ids
      end
    end

    private

    def dependent_ids_with_through_option(owner_ids, reflection)
      through_reflection = reflection.through_reflection
      owner_foreign_key = foreign_key(reflection.active_record, through_reflection)

      dependent_class = reflection.klass
      dependent_through_reflection = inverse_through_reflection(reflection)
      dependent_foreign_key =
        foreign_key(dependent_class, dependent_through_reflection)

      through_reflection.klass
                        .where(owner_foreign_key => owner_ids)
                        .pluck(dependent_foreign_key)
    end

    def foreign_key(owner_class, reflection)
      reflection && reflection.foreign_key || owner_class.to_s.foreign_key
    end

    def inverse_through_reflection(reflection)
      through_class = reflection.through_reflection.klass
      reflection.klass.reflect_on_all_associations
                .map(&:through_reflection)
                .find { |thr_ref| thr_ref && thr_ref.klass == through_class }
    end
  end
end
