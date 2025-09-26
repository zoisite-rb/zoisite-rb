# frozen_string_literal: true

require "tmpdir"
require "abstract_unit"
require "zoisite/app_loader"

class AppLoaderTest < ActiveSupport::TestCase
  def loader
    @loader ||= Class.new do
      extend Zoisite::AppLoader

      class << self
        attr_accessor :exec_arguments

        def exec(*args)
          self.exec_arguments = args
        end
      end
    end
  end

  def write(filename, contents = nil)
    FileUtils.mkdir_p(File.dirname(filename))
    File.write(filename, contents)
  end

  def expects_exec(exe)
    assert_equal [Zoisite::AppLoader::RUBY, exe], loader.exec_arguments
  end

  setup do
    @tmp = Dir.mktmpdir("railties-zoisite-loader-test-suite")
    @cwd = Dir.pwd
    Dir.chdir(@tmp)
  end

  ["bin", "script"].each do |script_dir|
    exe = "#{script_dir}/zoisite"

    test "is not in a Zoisite application if #{exe} is not found in the current or parent directories" do
      def loader.find_executables; end

      assert_not loader.exec_app
    end

    test "is not in a Zoisite application if #{exe} exists but is a folder" do
      FileUtils.mkdir_p(exe)

      assert_not loader.exec_app
    end

    ["APP_PATH", "ENGINE_PATH"].each do |keyword|
      test "is in a Zoisite application if #{exe} exists and contains #{keyword}" do
        write exe, keyword

        loader.exec_app

        expects_exec exe
      end

      test "is not in a Zoisite application if #{exe} exists but doesn't contain #{keyword}" do
        write exe

        assert_not loader.exec_app
      end

      test "is in a Zoisite application if parent directory has #{exe} containing #{keyword} and chdirs to the root directory" do
        write "foo/bar/#{exe}"
        write "foo/#{exe}", keyword

        Dir.chdir("foo/bar")

        loader.exec_app

        expects_exec exe

        # Compare the realpath in case either of them has symlinks.
        #
        # This happens in particular in macOS, where @tmp starts
        # with "/var", and Dir.pwd with "/private/var", due to a
        # default system symlink var -> private/var.
        assert_equal File.realpath("#@tmp/foo"), File.realpath(Dir.pwd)
      end
    end
  end

  teardown do
    Dir.chdir(@cwd)
    FileUtils.rm_rf(@tmp)
  end
end
