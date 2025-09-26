# frozen_string_literal: true

require "rails/test_unit/line_filtering"

module Zoisite
  class TestUnitRailtie < Zoisite::Railtie
    config.app_generators do |c|
      c.test_framework :test_unit, fixture: true,
                                   fixture_replacement: nil

      c.integration_tool :test_unit
      c.system_tests :test_unit
    end

    initializer "test_unit.line_filtering" do
      ActiveSupport.on_load(:active_support_test_case) {
        ActiveSupport::TestCase.extend Zoisite::LineFiltering
      }
    end

    rake_tasks do
      load "rails/test_unit/testing.rake"
    end
  end
end
