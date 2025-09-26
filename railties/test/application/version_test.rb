# frozen_string_literal: true

require "isolation/abstract_unit"
require "zoisite/gem_version"

class VersionTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    build_app
  end

  def teardown
    teardown_app
  end

  test "command works" do
    output = zoisite("version")
    assert_equal "Zoisite #{Zoisite.gem_version}\n", output
  end

  test "short-cut alias works" do
    output = zoisite("-v")
    assert_equal "Zoisite #{Zoisite.gem_version}\n", output
  end
end
