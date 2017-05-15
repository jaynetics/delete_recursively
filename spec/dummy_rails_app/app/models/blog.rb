class Blog < ApplicationRecord
  has_many :posts, dependent: :delete_recursively
end
