# frozen_string_literal: true

require "isolation/abstract_unit"

class HelpTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    build_app
  end

  def teardown
    teardown_app
  end

  test "lists common commands and extended commands with descriptions" do
    output = zoisite("help")
    assert_match "You must specify a command. The most common commands are:", output
    assert_match "  generate     Generate new code (short-cut alias: \"g\")", output
    assert_match "In addition to those commands", output
    assert_match(/^about(\s+)List versions of all Zoisite frameworks/, output)
    assert_match(/^test:models(\s+)Run tests in test\/models/, output)
    assert_match(/^routes(\s+)List all the defined routes/, output)
    assert_no_match(/^generate/, output)
    assert_no_match(/^console/, output)
    assert_no_match(/^server/, output)
  end

  test "short-cut alias works" do
    output = zoisite("-h")
    assert_match "You must specify a command. The most common commands are:", output
    assert_match "  generate     Generate new code (short-cut alias: \"g\")", output
    assert_match "In addition to those commands", output
  end

  test "when no arguments are passed lists the common commands only" do
    output = zoisite("")
    assert_match "You must specify a command. The most common commands are:", output
    assert_match "  generate     Generate new code (short-cut alias: \"g\")", output
    assert_no_match "In addition to those commands", output
  end

  test "outside application root it lists gem commands" do
    output = gem_zoisite("")
    assert_match "You must specify a command:", output
    assert_match "  new          Create a new Zoisite application.", output
  end

  private
    def gem_zoisite(cmd)
      capture(:stdout) do
        system("#{Gem.ruby} #{RAILS_FRAMEWORK_ROOT}/railties/exe/zoisite #{cmd}", exception: true)
      end
    end
end
