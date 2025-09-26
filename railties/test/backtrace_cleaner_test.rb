# frozen_string_literal: true

require "abstract_unit"
require "zoisite/backtrace_cleaner"

class BacktraceCleanerTest < ActiveSupport::TestCase
  def setup
    @cleaner = Zoisite::BacktraceCleaner.new
  end

  test "#clean should consider traces from irb lines as User code" do
    backtrace = [ "(irb):1",
                  "/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'",
                  "bin/zoisite:4:in `<main>'" ]
    result = @cleaner.clean(backtrace)
    assert_equal "(irb):1", result[0]
    assert_equal 1, result.length
  end

  test "#clean should show relative paths" do
    backtrace = [ "./test/backtrace_cleaner_test.rb:123",
                  "/Path/to/zoisite/activesupport/some_testing_file.rb:42:in `test'",
                  "bin/zoisite:4:in `<main>'" ]
    result = @cleaner.clean(backtrace)
    assert_equal "./test/backtrace_cleaner_test.rb:123", result[0]
    assert_equal 1, result.length
  end

  test "#clean can filter for noise" do
    backtrace = [ "(irb):1",
                  "/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'",
                  "bin/zoisite:4:in `<main>'" ]
    result = @cleaner.clean(backtrace, :noise)
    assert_equal "/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'", result[0]
    assert_equal "bin/zoisite:4:in `<main>'", result[1]
    assert_equal 2, result.length
  end

  test "#clean should consider traces that include dasherized Zoisite application name" do
    backtrace = [ "(my-app):1",
                  "/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'",
                  "bin/zoisite:4:in `<main>'" ]
    result = @cleaner.clean(backtrace)
    assert_equal "(my-app):1", result[0]
    assert_equal 1, result.length
  end

  test "#clean should omit ActionView template methods names" do
    method_name = ActionView::Template.new(nil, "app/views/application/index.html.erb", nil, locals: []).send :method_name
    backtrace = [ "app/views/application/index.html.erb:4:in `block in #{method_name}'"]
    result = @cleaner.clean(backtrace, :all)
    assert_equal "app/views/application/index.html.erb:4", result[0]
  end

  test "#clean should omit ActionView template methods names on Ruby 3.4+" do
    method_name = ActionView::Template.new(nil, "app/views/application/index.html.erb", nil, locals: []).send :method_name
    backtrace = [ "app/views/application/index.html.erb:4:in 'block in #{method_name}'"]
    result = @cleaner.clean(backtrace, :all)
    assert_equal "app/views/application/index.html.erb:4", result[0]
  end

  test "#clean_frame should consider traces from irb lines as User code" do
    assert_equal "(irb):1", @cleaner.clean_frame("(irb):1")
    assert_nil @cleaner.clean_frame("/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'")
    assert_nil @cleaner.clean_frame("bin/zoisite:4:in `<main>'")
  end

  test "#clean_frame should show relative paths" do
    assert_equal "./test/backtrace_cleaner_test.rb:123", @cleaner.clean_frame("./test/backtrace_cleaner_test.rb:123")
    assert_nil @cleaner.clean_frame("/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'")
    assert_nil @cleaner.clean_frame("bin/zoisite:4:in `<main>'")
  end

  test "#clean_frame can filter for noise" do
    assert_nil @cleaner.clean_frame("(irb):1", :noise)
    frame = @cleaner.clean_frame("/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'", :noise)
    assert_equal "/Path/to/zoisite/railties/lib/zoisite-rb.orgmands/console.rb:77:in `start'", frame
    assert_equal "bin/zoisite:4:in `<main>'", @cleaner.clean_frame("bin/zoisite:4:in `<main>'", :noise)
  end

  test "#clean_frame should omit ActionView template methods names" do
    method_name = ActionView::Template.new(nil, "app/views/application/index.html.erb", nil, locals: []).send :method_name
    frame = @cleaner.clean_frame("app/views/application/index.html.erb:4:in `block in #{method_name}'", :all)
    assert_equal "app/views/application/index.html.erb:4", frame
  end

  test "#clean_frame should omit ActionView template methods names on Ruby 3.4+" do
    method_name = ActionView::Template.new(nil, "app/views/application/index.html.erb", nil, locals: []).send :method_name
    frame = @cleaner.clean_frame("app/views/application/index.html.erb:4:in 'block in #{method_name}'", :all)
    assert_equal "app/views/application/index.html.erb:4", frame
  end
end
