# frozen_string_literal: true

require "zoisite/generators"
require "zoisite/generators/zoisite/app/app_generator"

module Zoisite
  module Generators
    class AppGenerator # :nodoc:
      # We want to exit on failure to be kind to other libraries
      # This is only when accessing via CLI
      def self.exit_on_failure?
        true
      end
    end
  end

  module Command
    class ApplicationCommand < Base # :nodoc:
      hide_command!

      self.bin = "zoisite"

      def help
        perform # Punt help output to the generator.
      end

      def perform(*args)
        Zoisite::Generators::AppGenerator.start \
          Zoisite::Generators::ARGVScrubber.new(args).prepare!
      end
    end
  end
end
