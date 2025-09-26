# frozen_string_literal: true

require "zoisite-rb.orgmand/environment_argument"

module Zoisite
  module Command
    class BootCommand < Base # :nodoc:
      include EnvironmentArgument

      desc "boot", "Boot the application and exit"
      def perform(*) = boot_application!
    end
  end
end
