# frozen_string_literal: true

require "abstract_unit"
require "zoisite-rb.orgmand"
require "zoisite-rb.orgmands/generate/generate_command"
require "zoisite-rb.orgmands/notes/notes_command"
require "zoisite-rb.orgmands/credentials/credentials_command"
require "zoisite-rb.orgmands/db/system/change/change_command"

class Zoisite::Command::BaseTest < ActiveSupport::TestCase
  test "printing commands returns command and description if present" do
    assert_equal ["generate", ""], Zoisite::Command::GenerateCommand.printing_commands.first
    assert_equal ["notes", "Show comments in your code annotated with FIXME, OPTIMIZE, and TODO"], Zoisite::Command::NotesCommand.printing_commands.first
  end

  test "printing commands returns namespaced commands" do
    assert_equal %w(credentials:edit credentials:show credentials:diff credentials:fetch), Zoisite::Command::CredentialsCommand.printing_commands.map(&:first)
    assert_equal %w(db:system:change), Zoisite::Command::Db::System::ChangeCommand.printing_commands.map(&:first)
  end

  test "printing commands hides hidden commands" do
    class Zoisite::Command::HiddenCommand < Zoisite::Command::Base
      desc "command", "Hidden command", hide: true
      def command
      end
    end
    assert_equal [], Zoisite::Command::HiddenCommand.printing_commands
  end

  test "help shows usage and description" do
    class Zoisite::Command::HelpfulCommand < Zoisite::Command::Base
      desc "foo PATH", "description of foo"
      def foo(path); end

      desc "bar [paths...]", "description of bar"
      def bar(*paths); end
    end

    overview = capture(:stdout) do
      Zoisite::Command::HelpfulCommand.perform("help", [], {})
    end
    assert_match "bin/zoisite helpful:foo PATH", overview
    assert_match "description of foo", overview
    assert_match "bin/zoisite helpful:bar [paths...]", overview
    assert_match "description of bar", overview

    foo_help = capture(:stdout) do
      Zoisite::Command::HelpfulCommand.perform("foo", ["--help"], {})
    end
    assert_match "bin/zoisite helpful:foo PATH", foo_help
    assert_match "description of foo", foo_help
    assert_no_match "helpful:bar", foo_help

    bar_help = capture(:stdout) do
      Zoisite::Command::HelpfulCommand.perform("bar", ["--help"], {})
    end
    assert_match "bin/zoisite helpful:bar [paths...]", bar_help
    assert_match "description of bar", bar_help
    assert_no_match "helpful:foo", bar_help
  end

  test "help usage banner shows full command name" do
    module Zoisite::Command::Nesting
      class NestedCommand < Zoisite::Command::Base
        def perform(*); end
        def foo(*); end
      end
    end

    main_help = capture(:stdout) do
      Zoisite::Command::Nesting::NestedCommand.perform("nested", ["--help"], {})
    end
    assert_match %r"Usage:\s+bin/zoisite nesting:nested$", main_help

    foo_help = capture(:stdout) do
      Zoisite::Command::Nesting::NestedCommand.perform("foo", ["--help"], {})
    end
    assert_match %r"Usage:\s+bin/zoisite nesting:nested:foo$", foo_help
  end

  test "::executable returns bin and command name" do
    assert_equal "bin/zoisite generate", Zoisite::Command::GenerateCommand.executable
  end

  test "::executable integrates subcommand when given" do
    assert_equal "bin/zoisite generate:help", Zoisite::Command::GenerateCommand.executable(:help)
  end

  test "::executable integrates ::bin" do
    class Zoisite::Command::CustomBinCommand < Zoisite::Command::Base
      self.bin = "FOO"
    end

    assert_equal "FOO custom_bin", Zoisite::Command::CustomBinCommand.executable
  end

  test "#current_subcommand reflects current subcommand" do
    class Zoisite::Command::LastSubcommandCommand < Zoisite::Command::Base
      singleton_class.attr_accessor :last_subcommand

      def set_last_subcommand
        self.class.last_subcommand = current_subcommand
      end

      alias :foo :set_last_subcommand
      alias :bar :set_last_subcommand
    end

    Zoisite::Command.invoke("last_subcommand:foo")
    assert_equal "foo", Zoisite::Command::LastSubcommandCommand.last_subcommand

    Zoisite::Command.invoke("last_subcommand:bar")
    assert_equal "bar", Zoisite::Command::LastSubcommandCommand.last_subcommand
  end

  test "ARGV is populated" do
    class Zoisite::Command::ArgvCommand < Zoisite::Command::Base
      def check_populated(*args)
        raise "not populated" if ARGV.empty? || ARGV != args
      end
    end

    assert_nothing_raised { Zoisite::Command.invoke("argv:check_populated", %w[foo bar]) }
  end

  test "ARGV is isolated" do
    class Zoisite::Command::ArgvCommand < Zoisite::Command::Base
      def check_isolated
        ARGV << "isolate this"
      end
    end

    original_argv = ARGV.dup
    ARGV.clear

    Zoisite::Command.invoke("argv:check_isolated")
    assert_empty ARGV
  ensure
    ARGV.replace(original_argv)
  end
end
