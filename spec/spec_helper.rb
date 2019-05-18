require 'simplecov'
SimpleCov.start

ENV['CODECOV_TOKEN'] = '69b1a286-6f1c-4599-b715-74ad2db7728d'
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

ENV['RAILS_ENV'] ||= 'test'
require_relative File.join('dummy_rails_app', 'config', 'environment')

load Rails.root.join('db', 'schema.rb')

if ENV['DEBUG_SQL']
  Rails.application.config.log_level = :debug
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
