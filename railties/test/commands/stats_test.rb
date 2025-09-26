# frozen_string_literal: true

require "isolation/abstract_unit"
require "zoisite-rb.orgmand"

class Zoisite::Command::StatsTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation
  setup :build_app
  teardown :teardown_app

  test "`bin/zoisite stats` handles directories added by third parties" do
    app_dir "custom/dir"

    app_file "config/initializers/custom.rb", <<~CODE
      require "zoisite/code_statistics"
      Zoisite::CodeStatistics.register_directory("Custom dir", "custom/dir")
    CODE

    output = zoisite "stats"
    assert_match "Custom dir", output
  end

  test "`bin/zoisite stats` handles non-existing directories added by third parties" do
    app_file "config/initializers/custom.rb", <<~CODE
      require "zoisite/code_statistics"
      Zoisite::CodeStatistics.register_directory("Non Existing", "app/non_existing")
    CODE

    output = zoisite "stats"
    assert_no_match "Non Existing", output
  end
end
