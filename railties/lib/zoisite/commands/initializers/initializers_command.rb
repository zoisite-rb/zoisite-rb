# frozen_string_literal: true

require "zoisite/command/environment_argument"

module Zoisite
  module Command
    class InitializersCommand < Base # :nodoc:
      include EnvironmentArgument

      desc "initializers", "Print out all defined initializers in the order they are invoked by Zoisite."
      def perform
        boot_application!

        Zoisite.application.initializers.tsort_each do |initializer|
          say "#{initializer.context_class}.#{initializer.name}"
        end
      end
    end
  end
end
