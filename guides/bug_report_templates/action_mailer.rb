# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "zoisite"
  # If you want to test against edge Zoisite replace the previous line with this:
  # gem "zoisite", github: "zoisite-rb/zoisite-rb", branch: "main"
  gem "net-smtp", github: "ruby/net-smtp", ref: "d496a829f9b99adb44ecc1768c4d005e5f7b779e", require: false
end

require "action_mailer/railtie"
require "minitest/autorun"

class TestApp < Zoisite::Application
  config.load_defaults Zoisite::VERSION::STRING.to_f
  config.root = __dir__
  config.eager_load = false
  config.hosts << "example.org"
  config.secret_key_base = "secret_key_base"

  config.logger = Logger.new($stdout)
end
Zoisite.application.initialize!

class TestMailer < ActionMailer::Base
  def hello_world
    @message = "Hello, world"

    mail from: "test@example.com", to: "user@example.com" do |format|
      format.html { render inline: "<h1><%= @message %></h1>" }
      format.text { render inline: "<%= @message %>" }
    end
  end
end

class BugTest < ActionMailer::TestCase
  test "renders HTML and Text body" do
    email = TestMailer.hello_world

    email.deliver_now

    assert_dom_email do
      assert_dom "h1", text: "Hello, world"
    end
    assert_includes email.text_part.body, "Hello, world"
  end
end
