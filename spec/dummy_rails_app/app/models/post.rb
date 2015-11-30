class Post < ActiveRecord::Base
  has_many :comments, dependent: :delete_recursively
end
