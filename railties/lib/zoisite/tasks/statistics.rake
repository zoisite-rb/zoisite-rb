# frozen_string_literal: true

require "zoisite/code_statistics"
STATS_DIRECTORIES = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(
  Zoisite::CodeStatistics::DIRECTORIES,
  "`STATS_DIRECTORIES` is deprecated and will be removed in Zoisite 8.1! Use `Zoisite::CodeStatistics.register_directory('My Directory', 'path/to/dir)` instead.",
  Zoisite.deprecator
)

desc "Report code statistics (KLOCs, etc) from the application or engine"
task :stats do
  require "zoisite/code_statistics"
  stat_directories = STATS_DIRECTORIES.collect do |name, dir|
    [ name, "#{File.dirname(Rake.application.rakefile_location)}/#{dir}" ]
  end.select { |name, dir| File.directory?(dir) }

  $stderr.puts Zoisite.deprecator.warn(<<~MSG, caller_locations(0..1))
  `bin/rake stats` has been deprecated and will be removed in Zoisite 8.1.
  Please use `bin/zoisite stats` as Zoisite command instead.\n
  MSG

  Zoisite::CodeStatistics.new(*stat_directories).to_s
end
