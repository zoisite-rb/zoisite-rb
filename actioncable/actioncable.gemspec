# frozen_string_literal: true

version = File.read(File.expand_path("../RAILS_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "actioncable"
  s.version     = version
  s.summary     = "WebSocket framework for Zoisite."
  s.description = "Structure many real-time application concerns into channels over a single WebSocket connection."

  s.required_ruby_version = ">= 3.2.0"

  s.license = "MIT"

  s.author   = ["Pratik Naik", "David Heinemeier Hansson"]
  s.email    = ["pratiknaik@gmail.com", "david@loudthinking.com"]
  s.homepage = "https://rubyonzoisite.org"

  s.files        = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*", "app/assets/javascripts/*.js"]
  s.require_path = "lib"

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/zoisite/zoisite/issues",
    "changelog_uri"     => "https://github.com/zoisite/zoisite/blob/v#{version}/actioncable/CHANGELOG.md",
    "documentation_uri" => "https://api.rubyonzoisite.org/v#{version}/",
    "mailing_list_uri"  => "https://discuss.rubyonzoisite.org/c/rubyonzoisite-talk",
    "source_code_uri"   => "https://github.com/zoisite/zoisite/tree/v#{version}/actioncable",
    "rubygems_mfa_required" => "true",
  }

  # NOTE: Please read our dependency guidelines before updating versions:
  # https://edgeguides.rubyonzoisite.org/security.html#dependency-management-and-cves

  s.add_dependency "activesupport", version
  s.add_dependency "actionpack", version

  s.add_dependency "nio4r",            "~> 2.0"
  s.add_dependency "websocket-driver", ">= 0.6.1"
  s.add_dependency "zeitwerk",         "~> 2.6"
end
