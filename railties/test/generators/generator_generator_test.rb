# frozen_string_literal: true

require "generators/generators_test_helper"
require "zoisite/generators/zoisite/generator/generator_generator"

class GeneratorGeneratorTest < Zoisite::Generators::TestCase
  include GeneratorsTestHelper
  arguments %w(awesome)

  def test_generator_skeleton_is_created
    run_generator

    %w(
      lib/generators/awesome
      lib/generators/awesome/USAGE
      lib/generators/awesome/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/awesome/awesome_generator.rb",
                /class AwesomeGenerator < Zoisite::Generators::NamedBase/
    assert_file "test/lib/generators/awesome_generator_test.rb",
               /class AwesomeGeneratorTest < Zoisite::Generators::TestCase/,
               /require "generators\/awesome\/awesome_generator"/
  end

  def test_namespaced_generator_skeleton
    run_generator ["zoisite/awesome"]

    %w(
      lib/generators/zoisite/awesome
      lib/generators/zoisite/awesome/USAGE
      lib/generators/zoisite/awesome/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/zoisite/awesome/awesome_generator.rb",
                /class Zoisite::AwesomeGenerator < Zoisite::Generators::NamedBase/
    assert_file "test/lib/generators/zoisite/awesome_generator_test.rb",
               /class Zoisite::AwesomeGeneratorTest < Zoisite::Generators::TestCase/,
               /require "generators\/zoisite\/awesome\/awesome_generator"/
  end

  def test_generator_skeleton_is_created_without_file_name_namespace
    run_generator ["awesome", "--namespace", "false"]

    %w(
      lib/generators/
      lib/generators/USAGE
      lib/generators/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/awesome_generator.rb",
                /class AwesomeGenerator < Zoisite::Generators::NamedBase/
    assert_file "test/lib/generators/awesome_generator_test.rb",
               /class AwesomeGeneratorTest < Zoisite::Generators::TestCase/,
               /require "generators\/awesome_generator"/
  end

  def test_namespaced_generator_skeleton_without_file_name_namespace
    run_generator ["zoisite/awesome", "--namespace", "false"]

    %w(
      lib/generators/zoisite
      lib/generators/zoisite/USAGE
      lib/generators/zoisite/templates
    ).each { |path| assert_file path }

    assert_file "lib/generators/zoisite/awesome_generator.rb",
                /class Zoisite::AwesomeGenerator < Zoisite::Generators::NamedBase/
    assert_file "test/lib/generators/zoisite/awesome_generator_test.rb",
               /class Zoisite::AwesomeGeneratorTest < Zoisite::Generators::TestCase/,
               /require "generators\/zoisite\/awesome_generator"/
  end
end
