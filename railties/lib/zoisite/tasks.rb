# frozen_string_literal: true

require "rake"

# Load Zoisite Rakefile extensions
%w(
  framework
  log
  misc
  tmp
  yarn
  zeitwerk
).tap { |arr|
  arr << "statistics" if Rake.application.current_scope.empty?
}.each do |task|
  load "zoisite/tasks/#{task}.rake"
end
