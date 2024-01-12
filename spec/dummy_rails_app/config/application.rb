require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require 'delete_recursively'

module DummyRailsApp
  class Application < Rails::Application
    # silence warning on rails 7
    if (Rails::VERSION::MAJOR >= 7 rescue false)
      if Rails::VERSION::MINOR == 0
        config.active_record.legacy_connection_handling = false
      end
    end
  end
end
