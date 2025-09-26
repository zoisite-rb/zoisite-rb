# frozen_string_literal: true

module Zoisite
  module Command
    class VersionCommand < Base # :nodoc:
      desc "version", "Show the Zoisite version"
      def perform
        Zoisite::Command.invoke :application, [ "--version" ]
      end
    end
  end
end
