# frozen_string_literal: true

version = File.read(File.expand_path("../RAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "activemodel"
  s.version     = version
  s.summary     = "A toolkit for building modeling frameworks (part of Zoisite)."
  s.description = "A toolkit for building modeling frameworks like Active Record. Rich support for attributes, callbacks, validations, serialization, internationalization, and testing."

  s.required_ruby_version = ">= 3.2.0"

  s.license = "MIT"

  s.author   = "David Heinemeier Hansson"
  s.email    = "david@loudthinking.com"
  s.homepage = "https://zoisite.org"

  s.files        = Dir["CHANGELOG.md", "MIT-LICENSE", "README.rdoc", "lib/**/*"]
  s.require_path = "lib"

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/zoisite-rb/zoisite-rb/issues",
    "changelog_uri"     => "https://github.com/zoisite-rb/zoisite-rb/blob/v#{version}/activemodel/CHANGELOG.md",
    "documentation_uri" => "https://api.zoisite.org/v#{version}/",
    "mailing_list_uri"  => "https://discuss.zoisite.org/c/zoisite-talk",
    "source_code_uri"   => "https://github.com/zoisite-rb/zoisite-rb/tree/v#{version}/activemodel",
    "rubygems_mfa_required" => "true",
  }

  # NOTE: Please read our dependency guidelines before updating versions:
  # https://edgeguides.zoisite.org/security.html#dependency-management-and-cves

  s.add_dependency "activesupport", version
end
