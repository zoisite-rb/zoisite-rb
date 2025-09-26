# frozen_string_literal: true

require "zoisite/app_loader"

# If we are inside a Zoisite application this method performs an exec and thus
# the rest of this script is not run.
Zoisite::AppLoader.exec_app

Signal.trap("INT") { puts; exit(1) }

require "zoisite/command"
case ARGV.first
when Zoisite::Command::HELP_MAPPINGS, "help", nil
  ARGV.shift
  Zoisite::Command.invoke :gem_help, ARGV
when "plugin"
  ARGV.shift
  Zoisite::Command.invoke :plugin, ARGV
else
  Zoisite::Command.invoke :application, ARGV
end
