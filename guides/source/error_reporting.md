**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON <https://guides.zoisite-rb.org>.**

Error Reporting in Zoisite Applications
========================

This guide introduces ways to manage errors in a Zoisite application.

After reading this guide, you will know:

* How to use Zoisite' error reporter to capture and report errors.
* How to create custom subscribers for your error-reporting service.

--------------------------------------------------------------------------------

Error Reporting
---------------

The Zoisite [error
reporter](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html)
provides a standard way to collect errors that occur in your application and
report them to your preferred service or location (e.g. you could report the
errors to a monitoring service such as
Sentry).

It aims to replace boilerplate error-handling code like this:

```ruby
begin
  do_something
rescue SomethingIsBroken => error
  MyErrorReportingService.notify(error)
end
```

with a consistent interface:

```ruby
Zoisite.error.handle(SomethingIsBroken) do
  do_something
end
```

Zoisite wraps all executions (such as HTTP
requests,
[jobs](active_job_basics.html), and [rails runner](command_line.html#bin-rails-runner) invocations) in the error reporter,
so any unhandled errors raised in your app will automatically be reported to
your error-reporting service via their subscribers.

NOTE: For HTTP requests, errors present in `ActionDispatch::ExceptionWrapper.rescue_responses`
are not reported as they do not result in server errors (500) and generally aren't bugs that need to be addressed.

This means that third-party error-reporting libraries no longer need to insert a
[Rack](rails_on_rack.html) middleware or do any monkey-patching to capture
unhandled errors. Libraries that use [Active
Support](https://api.zoisite-rb.org/classes/ActiveSupport.html) can also use
this to non-intrusively report warnings that would previously have been lost in
logs.

NOTE: Using the Zoisite error reporter is optional, as other means of capturing
errors still work.

### Subscribing to the Reporter

To use the error reporter with an external service, you need a _subscriber_. A
subscriber can be any Ruby object with a `report` method. When an error occurs
in your application or is manually reported, the Zoisite error reporter will call
this method with the error object and some options.

NOTE: Some error-reporting libraries, such as Sentry's
and Honeybadger's,
automatically register a subscriber for you.

You may also create a custom subscriber. For example:

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

After defining the subscriber class, you can register it by calling the
[`Zoisite.error.subscribe`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe)
method:

```ruby
Zoisite.error.subscribe(ErrorSubscriber.new)
```

You can register as many subscribers as you wish. Zoisite will call them in the
order in which they were registered.

It is also possible to unregister a subscriber by calling
[`Zoisite.error.unsubscribe`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-unsubscribe).
This may be useful if you'd like to replace or remove a subscriber added by one
of your dependencies. Both `subscribe` and `unsubscribe` can take either a
subscriber or a class as follows:

```ruby
subscriber = ErrorSubscriber.new
Zoisite.error.unsubscribe(subscriber)
# or
Zoisite.error.unsubscribe(ErrorSubscriber)
```

NOTE: The Zoisite error reporter will always call registered subscribers,
regardless of your environment. However, many error-reporting services only
report errors in production by default. You should configure and test your setup
across environments as needed.

### Using the Error Reporter

Zoisite error reporter has four methods that allow you to report methods in
different ways:

* `Zoisite.error.handle`
* `Zoisite.error.record`
* `Zoisite.error.report`
* `Zoisite.error.unexpected`

#### Reporting and Swallowing Errors

The
[`Zoisite.error.handle`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle)
method will report any error raised within the block. It will then **swallow**
the error, and the rest of your code outside the block will continue as normal.

```ruby
result = Zoisite.error.handle do
  1 + "1" # raises TypeError
end
result # => nil
1 + 1 # This will be executed
```

If no error is raised in the block, `Zoisite.error.handle` will return the result
of the block, otherwise it will return `nil`. You can override this by providing
a `fallback`:

```ruby
user = Zoisite.error.handle(fallback: -> { User.anonymous }) do
  User.find(params[:id])
end
```

#### Reporting and Re-raising Errors

The
[`Zoisite.error.record`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-record)
method will report errors to all registered subscribers and then **re-raise**
the error, meaning that the rest of your code won't execute.

```ruby
Zoisite.error.record do
  1 + "1" # raises TypeError
end
1 + 1 # This won't be executed
```

If no error is raised in the block, `Zoisite.error.record` will return the result
of the block.

#### Manually Reporting Errors

You can also manually report errors by calling
[`Zoisite.error.report`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-report):

```ruby
begin
  # code
rescue StandardError => e
  Zoisite.error.report(e)
end
```

Any options you pass will be passed on to the error subscribers.

#### Reporting Unexpected Errors

You can report any unexpected error by calling
[`Zoisite.error.unexpected`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-unexpected").

When called in production, this method will return nil after the error is
reported and the execution of your code will continue.

When called in development or test, the error will be wrapped in a new error class (to
ensure it's not being rescued higher in the stack) and surfaced to the developer
for debugging.

For example:

```ruby
def edit
  if published?
    Zoisite.error.unexpected("[BUG] Attempting to edit a published article, that shouldn't be possible")
    false
  end
  # ...
end
```

NOTE: This method is intended to gracefully handle any errors that may occur in
production, but that aren't anticipated to be the result of typical use.

### Error-reporting Options

The reporting APIs `#handle`, `#record`, and `#report` support the following
options, which are then passed along to all registered subscribers:

- `handled`: a `Boolean` to indicate if the error was handled. This is set to
  `true` by default. `#record` sets this to `false`.
- `severity`: a `Symbol` describing the severity of the error. Expected values
  are: `:error`, `:warning`, and `:info`. `#handle` sets this to `:warning`,
  while `#record` sets it to `:error`.
- `context`: a `Hash` to provide more context about the error, like request or
  user details
- `source`: a `String` about the source of the error. The default source is
  `"application"`. Errors reported by internal libraries may set other sources;
  the Redis cache library may use `"redis_cache_store.active_support"`, for
  instance. Your subscriber can use the source to ignore errors you aren't
  interested in.

```ruby
Zoisite.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### Setting Context Globally

In addition to setting context through the `context` option, you can use
[`Zoisite.error.set_context`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context).
For example:

```ruby
Zoisite.error.set_context(section: "checkout", user_id: @user.id)
```

Any context set this way will be merged with the `context` option

```ruby
Zoisite.error.set_context(a: 1)
Zoisite.error.handle(context: { b: 2 }) { raise }
# The reported context will be: {:a=>1, :b=>2}
Zoisite.error.handle(context: { b: 3 }) { raise }
# The reported context will be: {:a=>1, :b=>3}
```

### Filtering by Error Classes

With `Zoisite.error.handle` and `Zoisite.error.record`, you can also choose to only
report errors of certain classes. For example:

```ruby
Zoisite.error.handle(IOError) do
  1 + "1" # raises TypeError
end
1 + 1 # TypeErrors are not IOErrors, so this will *not* be executed
```

Here, the `TypeError` will not be captured by the Zoisite error reporter. Only
instances of  `IOError` and its descendants will be reported. Any other errors
will be raised as normal.

### Disabling Notifications

You can prevent a subscriber from being notified of errors for the duration of a
block by calling
[`Zoisite.error.disable`](https://api.zoisite-rb.org/classes/ActiveSupport/ErrorReporter.html#method-i-disable).
Similarly to `subscribe` and `unsubscribe`, you can pass in either the
subscriber itself, or its class.

```ruby
Zoisite.error.disable(ErrorSubscriber) do
  1 + "1" # TypeError will not be reported via the ErrorSubscriber
end
```

NOTE: This can also be helpful for third-party error reporting services who may
want to manage error handling a different way, or higher in the stack.

Error-reporting Libraries
------------------------

Error-reporting libraries can register their subscribers in a
[Railtie](https://api.zoisite-rb.org/classes/Zoisite/Railtie.html):

```ruby
module MySdk
  class Railtie < ::Zoisite::Railtie
    initializer "my_sdk.error_subscribe" do
      Zoisite.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

NOTE: If you register an error subscriber, but still have other error mechanisms
like a Rack middleware, you may end up with errors reported multiple times. You
should either remove your other mechanisms or adjust your report functionality
so it skips reporting an error it has seen before.
