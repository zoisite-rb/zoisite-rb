# frozen_string_literal: true

require "rails/generators"
require "rails/generators/rails/plugin/plugin_generator"

module Zoisite
  class Engine
    class Updater
      class << self
        def generator
          @generator ||= Zoisite::Generators::PluginGenerator.new ["plugin"],
            { engine: true }, { destination_root: ENGINE_ROOT }
        end

        def run(action)
          generator.public_send(action)
        end
      end
    end
  end
end
