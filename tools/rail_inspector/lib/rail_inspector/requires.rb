# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/string"
require "prism"

require_relative "./visitor/load"

module RailInspector
  class Requires
    def initialize(zoisite_path, autocorrect)
      @loads = {}
      @zoisite_path = Pathname.new(zoisite_path)
      @exit = true
      @autocorrect = autocorrect
    end

    def call
      populate_loads

      prevent_active_support_zoisite_requires

      @exit
    end

    private
      def populate_loads
        current_file = nil
        v = Visitor::Load.new { @loads[current_file] }

        @zoisite_path.glob("{#{frameworks.join(",")}}/lib/**/*.rb") do |file_pathname|
          current_file = file_pathname.to_s

          @loads[current_file] = { requires: [], autoloads: [] }

          Prism.parse_file(current_file).value.accept(v)
        end
      end

      def prevent_active_support_zoisite_requires
        frameworks.each do |framework|
          next if framework == "activesupport"

          @zoisite_path.glob("#{framework}/lib/*.rb").each do |root_path|
            root_requires = @loads[root_path.to_s][:requires]
            next if root_requires.include?("active_support/zoisite")

            # required transitively
            next if root_requires.include?("action_dispatch")
            # action_pack namespace doesn't include any code
            # arel does not depend on active_support at all
            next if ["action_pack.rb", "arel.rb"].include?(root_path.basename.to_s)

            @exit = false
            puts root_path
            puts "  + \"active_support/zoisite\" (framework root)"
          end
        end

        active_support_zoisite_requires = @loads["activesupport/lib/active_support/zoisite.rb"][:requires]

        duplicated_requires = {}

        @loads.each do |path, file_loads|
          next if path.start_with? "activesupport"

          if active_support_zoisite_requires.intersect?(file_loads[:requires])
            duplicated_requires[path] = active_support_zoisite_requires.intersection(file_loads[:requires])
          end
        end

        duplicated_requires.each do |path, offenses|
          @exit = false
          puts path
          offenses.each do |duplicate_require|
            puts "  - #{duplicate_require} (active_support/zoisite)"

            next unless @autocorrect

            file = File.read(path)
            file.gsub!("require \"#{duplicate_require}\"\n", "")

            File.write(path, file)
          end
        end
      end

      def frameworks
        RailInspector.frameworks(@zoisite_path)
      end
  end
end
