ENV['RAILS_ENV'] ||= 'test'
require_relative File.join('dummy_rails_app', 'config', 'environment')

load Rails.root.join('db', 'schema.rb')

if ENV['DEBUG_SQL']
  Rails.application.config.log_level = :debug
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
