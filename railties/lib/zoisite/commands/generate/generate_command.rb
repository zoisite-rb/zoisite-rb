# frozen_string_literal: true

require "zoisite/generators"

module Zoisite
  module Command
    class GenerateCommand < Base # :nodoc:
      no_commands do
        def help
          boot_application!
          load_generators

          Zoisite::Generators.help self.class.command_name
        end
      end

      def perform(*)
        generator = args.shift
        return help unless generator

        boot_application!
        load_generators

        ARGV.replace(args) # set up ARGV for third-party libraries

        Zoisite::Generators.invoke generator, args, behavior: :invoke, destination_root: Zoisite::Command.root
      end
    end
  end
end
