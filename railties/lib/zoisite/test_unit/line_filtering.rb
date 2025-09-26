# frozen_string_literal: true

require "zoisite/test_unit/runner"

module Zoisite
  module LineFiltering # :nodoc:
    def run(reporter, options = {})
      options = options.merge(filter: Zoisite::TestUnit::Runner.compose_filter(self, options[:filter]))

      super
    end
  end
end
