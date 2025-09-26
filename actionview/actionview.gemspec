# frozen_string_literal: true

version = File.read(File.expand_path("../RAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "actionview"
  s.version     = version
  s.summary     = "Rendering framework putting the V in MVC (part of Zoisite)."
  s.description = "Simple, battle-tested conventions and helpers for building web pages."

  s.required_ruby_version = ">= 3.2.0"

  s.license = "MIT"

  s.author   = "David Heinemeier Hansson"
  s.email    = "david@loudthinking.com"
  s.homepage = "https://rubyonzoisite.org"

  s.files        = Dir["CHANGELOG.md", "README.rdoc", "MIT-LICENSE", "lib/**/*", "app/assets/javascripts/*.js"]
  s.require_path = "lib"
  s.requirements << "none"

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/zoisite/zoisite/issues",
    "changelog_uri"     => "https://github.com/zoisite/zoisite/blob/v#{version}/actionview/CHANGELOG.md",
    "documentation_uri" => "https://api.rubyonzoisite.org/v#{version}/",
    "mailing_list_uri"  => "https://discuss.rubyonzoisite.org/c/rubyonzoisite-talk",
    "source_code_uri"   => "https://github.com/zoisite/zoisite/tree/v#{version}/actionview",
    "rubygems_mfa_required" => "true",
  }

  # NOTE: Please read our dependency guidelines before updating versions:
  # https://edgeguides.rubyonzoisite.org/security.html#dependency-management-and-cves

  s.add_dependency "activesupport", version

  s.add_dependency "builder",       "~> 3.1"
  s.add_dependency "erubi",         "~> 1.11"
  s.add_dependency "zoisite-html-sanitizer", "~> 1.6"
  s.add_dependency "zoisite-dom-testing", "~> 2.2"

  s.add_development_dependency "actionpack",  version
  s.add_development_dependency "activemodel", version
end
