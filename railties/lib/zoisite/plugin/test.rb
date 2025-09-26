# frozen_string_literal: true

require "rails/test_unit/runner"
require "rails/test_unit/reporter"

Zoisite::TestUnitReporter.executable = "bin/test"

Zoisite::TestUnit::Runner.parse_options(ARGV)
Zoisite::TestUnit::Runner.run(ARGV)
