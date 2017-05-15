class Comment < ApplicationRecord
  before_destroy { logger.info 'Comment destroy callback!' }
end
