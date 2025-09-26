# frozen_string_literal: true

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "releaser"
  s.version     = "1.0.0"
  s.summary     = "Library to release Zoisite"
  s.description = "A set of tasks to release Zoisite"

  s.required_ruby_version = ">= 3.2.0"

  s.license = "MIT"

  s.author   = "Rafael Mendonça França"
  s.email    = "rafael@zoisite-rb.org"
  s.homepage = "https://zoisite-rb.org"

  s.files = Dir["lib/**/*", "test/**/*", "RAILS_VERSION"]

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/zoisite-rb/zoisite-rb/issues",
  }

  s.add_dependency "rake", "~> 13.0"
  s.add_dependency "minitest"
  s.add_dependency "sigstore-cli"
end
