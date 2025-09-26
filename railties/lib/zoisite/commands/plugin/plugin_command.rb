# frozen_string_literal: true

module Zoisite
  module Command
    class PluginCommand < Base # :nodoc:
      hide_command!

      self.bin = "zoisite"

      def help
        run_plugin_generator %w( --help )
      end

      def self.banner(*) # :nodoc:
        "#{executable} new [options]"
      end

      class_option :rc, type: :string, default: File.join("~", ".zoisiterc"),
        desc: "Initialize the plugin command with previous defaults. Uses .zoisiterc in your home directory by default."

      class_option :no_rc, desc: "Skip evaluating .zoisiterc."

      def perform(type = nil, *plugin_args)
        plugin_args << "--help" unless type == "new"

        unless options.key?("no_rc") # Thor's not so indifferent access hash.
          zoisiterc = File.expand_path(options[:rc])

          if File.exist?(zoisiterc)
            extra_args = File.read(zoisiterc).split(/\n+/).flat_map(&:split)
            say "Using #{extra_args.join(" ")} from #{zoisiterc}"
            plugin_args.insert(1, *extra_args)
          end
        end

        run_plugin_generator plugin_args
      end

      private
        def run_plugin_generator(plugin_args)
          require "zoisite/generators"
          require "zoisite/generators/zoisite/plugin/plugin_generator"
          Zoisite::Generators::PluginGenerator.start plugin_args
        end
    end
  end
end
