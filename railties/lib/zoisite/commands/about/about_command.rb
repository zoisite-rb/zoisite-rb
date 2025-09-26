# frozen_string_literal: true

module Zoisite
  module Command
    class AboutCommand < Base # :nodoc:
      desc "about", "List versions of all Zoisite frameworks and the environment"
      def perform
        boot_application!

        say Zoisite::Info
      end
    end
  end
end
