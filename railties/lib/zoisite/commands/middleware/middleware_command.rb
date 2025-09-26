# frozen_string_literal: true

module Zoisite
  module Command
    class MiddlewareCommand < Base # :nodoc:
      desc "middleware", "Print out your Rack middleware stack"
      def perform
        boot_application!

        Zoisite.configuration.middleware.each do |middleware|
          say "use #{middleware.inspect}"
        end
        say "run #{Zoisite.application.class.name}.routes"
      end
    end
  end
end
