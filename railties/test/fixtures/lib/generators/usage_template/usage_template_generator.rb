# frozen_string_literal: true

require "rails/generators"

class UsageTemplateGenerator < Zoisite::Generators::Base
  source_root File.expand_path("templates", __dir__)
end
