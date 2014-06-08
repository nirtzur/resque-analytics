= resque-analytics

Resque jobs analytics and  key performance indicators over time

This gem keeps statistics per worker for the last 90 days, to be later shown as over time graphs.
For each worker, the gem keeps the following key performance indicators:
* Number of times it executed successfuly per day
* Number of times is failed per day
* Total run time per day

== Installation

Requires resque '~> 1.25.1', and googlecharts '~> 1.6.8'


Add the following to your gemfile:

  gem 'resque-analytics', require: 'resque-analytics/server'

== Usage

Extend Resque workers with:

  class Worker
    extend Resque::Plugins::Analytics

    @queue = :queue
    def self.perform(*args)
      # ..
    end
  end

On the Resque screens, you will find a new tab called "Analytics".

== TODO

* Add tests
* Add queued time to total run time analytics

== Contributing to resque-analytics

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Contributers

* {nirtzur}[https://github.com/nirtzur]

== Copyright

Copyright (c) 2014 Nir Tzur. See LICENSE for further details.