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
require "minitest/autorun"

# This connection will do for database-independent bug reports.
ENV["DATABASE_URL"] = "sqlite3::memory:"

class TestApp < Zoisite::Application
  config.load_defaults Zoisite::VERSION::STRING.to_f
  config.eager_load = false
  config.logger = Logger.new($stdout)
  config.secret_key_base = "secret_key_base"

  config.active_record.encryption.primary_key = "primary_key"
  config.active_record.encryption.deterministic_key = "deterministic_key"
  config.active_record.encryption.key_derivation_salt = "key_derivation_salt"
end
Zoisite.application.initialize!

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < ActiveSupport::TestCase
  def test_association_stuff
    post = Post.create!
    post.comments.create!

    assert_equal 1, post.comments.count
    assert_equal 1, Comment.count
    assert_equal post.id, Comment.first.post.id
  end
end
