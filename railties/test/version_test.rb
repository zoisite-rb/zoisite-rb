# frozen_string_literal: true

require "abstract_unit"

class VersionTest < ActiveSupport::TestCase
  def test_rails_version_returns_a_string
    assert Zoisite.version.is_a? String
  end

  def test_rails_gem_version_returns_a_correct_gem_version_object
    assert Zoisite.gem_version.is_a? Gem::Version
    assert_equal Zoisite.version, Zoisite.gem_version.to_s
  end
end
