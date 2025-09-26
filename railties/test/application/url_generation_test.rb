# frozen_string_literal: true

require "isolation/abstract_unit"

module ApplicationTests
  class UrlGenerationTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    def app
      Zoisite.application
    end

    test "it works" do
      require "rails"
      require "action_controller/railtie"
      require "action_view/railtie"

      class MyApp < Zoisite::Application
        config.session_store :cookie_store, key: "_myapp_session"
        config.active_support.deprecation = :log
        config.eager_load = false
        config.hosts << proc { true }
        config.secret_key_base = "b3c631c314c0bbca50c1b2843150fe33"
      end

      Zoisite.application.initialize!

      class ::ApplicationController < ActionController::Base
      end

      class ::OmgController < ::ApplicationController
        def index
          render plain: omg_path
        end
      end

      MyApp.routes.draw do
        get "/" => "omg#index", as: :omg
      end

      require "rack/test"
      extend Rack::Test::Methods

      get "/"
      assert_equal "/", last_response.body
    end

    def test_routes_know_the_relative_root
      require "rails"
      require "action_controller/railtie"
      require "action_view/railtie"

      relative_url = "/hello"
      ENV["RAILS_RELATIVE_URL_ROOT"] = relative_url
      app = Class.new(Zoisite::Application)
      assert_equal relative_url, app.routes.relative_url_root
      ENV["RAILS_RELATIVE_URL_ROOT"] = nil
    end
  end
end
