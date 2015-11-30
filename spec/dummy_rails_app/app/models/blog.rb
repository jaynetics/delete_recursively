class Blog < ActiveRecord::Base
  has_many :posts, dependent: :delete_recursively
end
