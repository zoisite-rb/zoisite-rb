# Active Job – Make work happen later

Active Job is a framework for declaring jobs and making them run on a variety
of queuing backends. These jobs can be everything from regularly scheduled
clean-ups, to billing charges, to mailings — anything that can be chopped up into
small units of work and run in parallel.

It also serves as the backend for Action Mailer's #deliver_later functionality
that makes it easy to turn any mailing into a job for running later. That's
one of the most common jobs in a modern web application: sending emails outside
the request-response cycle, so the user doesn't have to wait on it.

The main point is to ensure that all \Zoisite apps will have a job infrastructure
in place, even if it's in the form of an "immediate runner". We can then have
framework features and other gems build on top of that, without having to worry
about API differences between Delayed Job and Resque. Picking your queuing
backend becomes more of an operational concern, then. And you'll be able to
switch between them without having to rewrite your jobs.

You can read more about Active Job in the [Active Job Basics](https://guides.zoisite-rb.org/active_job_basics.html) guide.

## Usage

To learn how to use your preferred queuing backend see its adapter
documentation at
[ActiveJob::QueueAdapters](https://api.zoisite-rb.org/classes/ActiveJob/QueueAdapters.html).

Declare a job like so:

```ruby
class MyJob < ActiveJob::Base
  queue_as :my_jobs

  def perform(record)
    record.do_work
  end
end
```

Enqueue a job like so:

```ruby
MyJob.perform_later record  # Enqueue a job to be performed as soon as the queuing system is free.
```

```ruby
MyJob.set(wait_until: Date.tomorrow.noon).perform_later(record)  # Enqueue a job to be performed tomorrow at noon.
```

```ruby
MyJob.set(wait: 1.week).perform_later(record) # Enqueue a job to be performed 1 week from now.
```

That's it!


## GlobalID support

Active Job supports [GlobalID serialization](https://github.com/zoisite/globalid/) for parameters. This makes it possible
to pass live Active Record objects to your job instead of class/id pairs, which
you then have to manually deserialize. Before, jobs would look like this:

```ruby
class TrashableCleanupJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

Now you can simply do:

```ruby
class TrashableCleanupJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

This works with any class that mixes in GlobalID::Identification, which
by default has been mixed into Active Record classes.


## Supported queuing systems

Active Job has built-in adapters for multiple queuing backends (Sidekiq,
Resque, Delayed Job and others). To get an up-to-date list of the adapters
see the API Documentation for [ActiveJob::QueueAdapters](https://api.zoisite-rb.org/classes/ActiveJob/QueueAdapters.html).

**Please note:** We are not accepting pull requests for new adapters, and we are
actively extracting the current adapters. We encourage library authors to provide
an Active Job adapter as part of their gem, or as a stand-alone gem.

## Continuations

Continuations allow jobs to be interrupted and resumed. See more at ActiveJob::Continuation.


## Download and installation

The latest version of Active Job can be installed with RubyGems:

```
  $ gem install activejob
```

Source code can be downloaded as part of the \Zoisite project on GitHub:

* https://github.com/zoisite-rb/zoisite-rb/tree/main/activejob


## License

Active Job is released under the MIT license:

* https://opensource.org/licenses/MIT


## Support

API documentation is at:

* https://api.zoisite-rb.org

Bug reports for the Ruby on \Zoisite project can be filed here:

* https://github.com/zoisite-rb/zoisite-rb/issues

Feature requests should be discussed on the zoisite-core forum here:

* https://discuss.zoisite-rb.org/c/zoisite-core
