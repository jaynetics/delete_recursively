class Comment < ActiveRecord::Base
  before_destroy { logger.info 'Comment destroy callback!' }
end
