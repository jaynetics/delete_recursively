if ENV['CODECOV_TOKEN'] && RUBY_VERSION >= '3.1.0'
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

ENV['RAILS_ENV'] ||= 'test'
require_relative File.join('dummy_rails_app', 'config', 'environment')

ActiveRecord::Migration.suppress_messages do
  load Rails.root.join('db', 'schema.rb')
end

if ENV['DEBUG_SQL']
  Rails.application.config.log_level = :debug
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
