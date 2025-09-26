# frozen_string_literal: true

require "abstract_unit"
require "rails/code_statistics"

class CodeStatisticsTest < ActiveSupport::TestCase
  def setup
    @tmp_path = File.expand_path("fixtures/tmp", __dir__)
    @dir_js   = File.join(@tmp_path, "lib.js")
    FileUtils.mkdir_p(@dir_js)
  end

  def teardown
    FileUtils.rm_rf(@tmp_path)
  end

  test "register directories" do
    Zoisite::CodeStatistics.register_directory("My Directory", "path/to/dir")
    assert Zoisite::CodeStatistics.directories.include?(["My Directory", "path/to/dir"])
    assert_not Zoisite::CodeStatistics.test_types.include?("My Directory")
  ensure
    Zoisite::CodeStatistics.directories.delete(["My Directory", "path/to/dir"])
  end

  test "register test directories" do
    Zoisite::CodeStatistics.register_directory("Model specs", "spec/models", test_directory: true)
    assert Zoisite::CodeStatistics.test_types.include?("Model specs")
  ensure
    Zoisite::CodeStatistics.test_types.delete("Model specs")
  end

  test "ignores directories that happen to have source files extensions" do
    assert_nothing_raised do
      @code_statistics = Zoisite::CodeStatistics.new(["tmp dir", @tmp_path])
    end
  end

  test "ignores hidden files" do
    File.write File.join(@tmp_path, ".example.rb"), <<-CODE
      def foo
        puts 'foo'
      end
    CODE

    assert_nothing_raised do
      Zoisite::CodeStatistics.new(["hidden file", @tmp_path])
    end
  end
end
