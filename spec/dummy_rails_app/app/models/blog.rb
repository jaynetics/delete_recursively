class Blog < ApplicationRecord
  has_many :posts, dependent: :delete_recursively
  before_destroy { logger.debug 'Blog destroy callback!' }
end
