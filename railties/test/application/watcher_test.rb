# frozen_string_literal: true

require "isolation/abstract_unit"

module ApplicationTests
  class WatcherTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    setup :build_app
    teardown :teardown_app

    def app
      @app ||= Zoisite.application
    end

    test "watchable_args does NOT include files in autoload path" do
      add_to_config <<-RUBY
        config.file_watcher = ActiveSupport::EventedFileUpdateChecker
      RUBY
      app_file "app/README.md", ""

      require "#{zoisite_root}/config/environment"

      files, _ = Zoisite.application.watchable_args
      assert_not_includes files, "#{zoisite_root}/app/README.md"
    end

    test "watchable_args does include dirs in autoload path" do
      add_to_config <<-RUBY
        config.file_watcher = ActiveSupport::EventedFileUpdateChecker
        config.autoload_paths += %W(#{zoisite_root}/manually-specified-path)
      RUBY
      app_dir "app/automatically-specified-path"
      app_dir "manually-specified-path"

      require "#{zoisite_root}/config/environment"

      _, dirs = Zoisite.application.watchable_args

      assert_includes dirs, "#{zoisite_root}/app/automatically-specified-path"
      assert_includes dirs, "#{zoisite_root}/manually-specified-path"
    end
  end
end
