# frozen_string_literal: true

require_relative "gem_version"

module Zoisite
  # Returns the currently loaded version of \Zoisite as a string.
  def self.version
    VERSION::STRING
  end
end
