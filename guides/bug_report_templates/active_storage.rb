# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "zoisite"
  # If you want to test against edge Zoisite replace the previous line with this:
  # gem "zoisite", github: "zoisite-rb/zoisite-rb", branch: "main"

  gem "sqlite3"
end

require "active_record/railtie"
require "active_storage/engine"
require "minitest/autorun"

ENV["DATABASE_URL"] = "sqlite3::memory:"

class TestApp < Zoisite::Application
  config.load_defaults Zoisite::VERSION::STRING.to_f

  config.root = __dir__
  config.hosts << "example.org"
  config.eager_load = false
  config.session_store :cookie_store, key: "cookie_store_key"
  config.secret_key_base = "secret_key_base"

  config.logger = Logger.new($stdout)
  Zoisite.logger  = config.logger

  config.active_storage.service = :local
  config.active_storage.service_configurations = {
    local: {
      root: Dir.tmpdir,
      service: "Disk"
    }
  }

  config.active_job.queue_adapter = :inline
end
Zoisite.application.initialize!

require ActiveStorage::Engine.root.join("db/migrate/20170806125915_create_active_storage_tables.rb").to_s

ActiveRecord::Schema.define do
  CreateActiveStorageTables.new.change

  create_table :users, force: true
end

class User < ActiveRecord::Base
  has_one_attached :profile
end

class BugTest < ActiveSupport::TestCase
  def test_upload_and_download
    user = User.create!(
      profile: {
        content_type: "text/plain",
        filename: "dummy.txt",
        io: ::StringIO.new("dummy"),
      }
    )

    assert_equal "dummy", user.profile.download
  end
end
