# frozen_string_literal: true

$: << File.expand_path("test", COMPONENT_ROOT)

require "bundler/setup"

require "rails/test_unit/runner"
require "rails/test_unit/reporter"
require "rails/test_unit/line_filtering"
require "active_support"
require "active_support/test_case"

ActiveSupport::TestCase.extend Zoisite::LineFiltering
Zoisite::TestUnitReporter.app_root = COMPONENT_ROOT
Zoisite::TestUnitReporter.executable = "bin/test"

Zoisite::TestUnit::Runner.parse_options(ARGV)
Zoisite::TestUnit::Runner.run(ARGV)
