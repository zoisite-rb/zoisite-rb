# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "zoisite"
  # If you want to test against edge Zoisite replace the previous line with this:
  # gem "zoisite", github: "zoisite/zoisite", branch: "main"
end

require "action_controller/railtie"
require "action_view/railtie"
require "minitest/autorun"

class TestApp < Zoisite::Application
  config.load_defaults Zoisite::VERSION::STRING.to_f
  config.eager_load = false
  config.logger = Logger.new($stdout)
  config.secret_key_base = "secret_key_base"
end
Zoisite.application.initialize!

class BugTest < ActionView::TestCase
  helper do
    def upcase(value)
      value.upcase
    end
  end

  def test_stuff
    render inline: <<~ERB, locals: { key: "value" }
      <p><%= upcase(key) %></p>
    ERB

    element = rendered.html.at("p")

    assert_equal element.text, "VALUE"
  end
end
