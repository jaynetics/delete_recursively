require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require 'delete_recursively'

module DummyRailsApp
  class Application < Rails::Application
  end
end
