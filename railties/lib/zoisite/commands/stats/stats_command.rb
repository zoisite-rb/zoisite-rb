# frozen_string_literal: true

module Zoisite
  module Command
    class StatsCommand < Base # :nodoc:
      desc "stats", "Report code statistics (KLOCs, etc) from the application or engine"
      def perform
        require "rails/code_statistics"
        boot_application!

        stat_directories = Zoisite::CodeStatistics.directories.map do |name, dir|
          [name, Zoisite::Command.application_root.join(dir)]
        end.select { |name, dir| File.directory?(dir) }

        Zoisite::CodeStatistics.new(*stat_directories).to_s
      end
    end
  end
end
