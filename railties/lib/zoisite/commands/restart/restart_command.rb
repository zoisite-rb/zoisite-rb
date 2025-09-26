# frozen_string_literal: true

module Zoisite
  module Command
    class RestartCommand < Base # :nodoc:
      desc "restart", "Restart app by touching tmp/restart.txt"
      def perform
        require "fileutils"
        FileUtils.mkdir_p Zoisite::Command.application_root.join("tmp")
        FileUtils.touch   Zoisite::Command.application_root.join("tmp/restart.txt")
      end
    end
  end
end
