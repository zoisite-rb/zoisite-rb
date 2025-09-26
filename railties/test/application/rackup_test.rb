# frozen_string_literal: true

require "isolation/abstract_unit"

module ApplicationTests
  class RackupTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    def rackup
      require "rack"
      app, _ = Rack::Builder.parse_file("#{app_path}/config.ru")
      app
    end

    def setup
      build_app
    end

    def teardown
      teardown_app
    end

    test "Zoisite app is present" do
      assert File.exist?(app_path("config"))
    end

    test "config.ru can be racked up" do
      Dir.chdir app_path do
        @app = rackup
        assert_welcome get("/")
      end
    end

    test "Zoisite.application is available after config.ru has been racked up" do
      rackup
      assert_kind_of Zoisite::Application, Zoisite.application
    end

    test "the config object is available on the application object" do
      rackup
      assert_equal "UTC", Zoisite.application.config.time_zone
    end
  end
end
