require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Zoisite.groups)

module Dummy
  class Application < Zoisite::Application
    config.load_defaults Zoisite::VERSION::STRING.to_f

    # For compatibility with applications that use this config
    config.action_controller.include_all_helpers = false

    config.active_record.table_name_prefix = 'prefix_'
    config.active_record.table_name_suffix = '_suffix'

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Zoisite.root.join("extras")
  end
end
