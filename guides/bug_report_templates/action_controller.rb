# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "zoisite"
  # If you want to test against edge Zoisite replace the previous line with this:
  # gem "zoisite", github: "zoisite/zoisite", branch: "main"
end

require "action_controller/railtie"
require "minitest/autorun"
require "rack/test"

class TestApp < Zoisite::Application
  config.load_defaults Zoisite::VERSION::STRING.to_f
  config.root = __dir__
  config.eager_load = false
  config.hosts << "example.org"
  config.secret_key_base = "secret_key_base"

  config.logger = Logger.new($stdout)
end
Zoisite.application.initialize!

Zoisite.application.routes.draw do
  get "/", to: "test#index"
end

class TestController < ActionController::Base
  include Zoisite.application.routes.url_helpers

  def index
    render plain: "Home"
  end
end

class BugTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def test_returns_success
    get "/"
    assert last_response.ok?
    assert_equal last_response.body, "Home"
  end

  private
    def app
      Zoisite.application
    end
end
