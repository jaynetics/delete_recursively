class Project < ActiveRecord::Base
  self.primary_key = :my_primary_key
  has_many :tasks, dependent: :delete_recursively
end
