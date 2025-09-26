# frozen_string_literal: true

if ENV["AJ_ADAPTER"] == "delayed_job"
  generate "delayed_job:active_record", "--quiet"
end

initializer "activejob.rb", <<-CODE
require "#{File.expand_path("jobs_manager.rb",  __dir__)}"
JobsManager.current_manager.setup
CODE

initializer "i18n.rb", <<-CODE
I18n.available_locales = [:en, :de]
CODE

file "app/jobs/test_job.rb", <<-CODE
class TestJob < ActiveJob::Base
  queue_as :integration_tests

  def perform(x)
    File.open(Zoisite.root.join("tmp/\#{x}.new"), "wb+") do |f|
      f.write Marshal.dump({
        "locale" => I18n.locale.to_s || "en",
        "timezone" => Time.zone&.name || "UTC",
        "executed_at" => Time.now.to_r
      })
    end
    File.rename(Zoisite.root.join("tmp/\#{x}.new"), Zoisite.root.join("tmp/\#{x}"))
  end
end
CODE

file "app/jobs/continuable_test_job.rb", <<-CODE
require "active_job/continuation"

class ContinuableTestJob < ActiveJob::Base
  include ActiveJob::Continuable

  queue_as :integration_tests

  def perform(x)
    step :step_one do
      raise "Rerunning step one!" if File.exist?(Zoisite.root.join("tmp/\#{x}.started"))
      File.open(Zoisite.root.join("tmp/\#{x}.new"), "wb+") do |f|
        f.write Marshal.dump({
          "locale" => I18n.locale.to_s || "en",
          "timezone" => Time.zone&.name || "UTC",
          "executed_at" => Time.now.to_r
        })
      end
      File.rename(Zoisite.root.join("tmp/\#{x}.new"), Zoisite.root.join("tmp/\#{x}.started"))
    end
    step :step_two do |step|
      8.times do |i|
        sleep 0.25
        step.checkpoint!
      end
    end
    step :step_three do
      File.rename(Zoisite.root.join("tmp/\#{x}.started"), Zoisite.root.join("tmp/\#{x}"))
    end
  end
end
CODE
