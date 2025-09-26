# frozen_string_literal: true

require "abstract_unit"
require "zoisite/command"

class Zoisite::Command::ApplicationTest < ActiveSupport::TestCase
  test "zoisite new without path prints help" do
    output = run_application_command "new"

    # Doesn't include the default thor error message:
    assert_not output.start_with?("No value provided for required arguments")

    # Includes contents of ~/railties/lib/zoisite/generators/zoisite/app/USAGE:
    assert output.include?("The `zoisite new` command creates a new Zoisite application with a default
    directory structure and configuration at the path you specify.")
  end

  private
    def run_application_command(*args)
      capture(:stdout) { Zoisite::Command.invoke(:application, args) }
    end
end
