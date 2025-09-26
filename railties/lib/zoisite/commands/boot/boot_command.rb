# frozen_string_literal: true

require "zoisite/command/environment_argument"

module Zoisite
  module Command
    class BootCommand < Base # :nodoc:
      include EnvironmentArgument

      desc "boot", "Boot the application and exit"
      def perform(*) = boot_application!
    end
  end
end
