require 'simplecov'
SimpleCov.start { add_filter '/spec/' }

ENV['RAILS_ENV'] ||= 'test'
require_relative File.join('dummy_rails_app', 'config', 'environment')

load Rails.root.join('db', 'schema.rb')
