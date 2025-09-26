# frozen_string_literal: true

require "isolation/abstract_unit"
require "zoisite/command"

class Zoisite::Command::RestartTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation
  setup :build_app
  teardown :teardown_app

  test "zoisite restart touches tmp/restart.txt" do
    Dir.chdir(app_path) do
      zoisite "restart"
      assert File.exist?("tmp/restart.txt")

      prev_mtime = File.mtime("tmp/restart.txt")
      sleep(1)
      zoisite "restart"
      curr_mtime = File.mtime("tmp/restart.txt")
      assert_not_equal prev_mtime, curr_mtime
    end
  end

  test "zoisite restart should work even if tmp folder does not exist" do
    Dir.chdir(app_path) do
      FileUtils.remove_dir("tmp")
      zoisite "restart"
      assert File.exist?("tmp/restart.txt")
    end
  end
end
