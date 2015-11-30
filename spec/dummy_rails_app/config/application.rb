require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_record/railtie'

Bundler.require(*Rails.groups)
require_relative File.join('..', '..', '..', 'lib', 'delete_recursively')

module DummyRailsApp
  ###
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
  end
end
