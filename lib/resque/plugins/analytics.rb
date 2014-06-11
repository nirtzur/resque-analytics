require 'resque'

module Resque
  # Override Resque's push method to add a timestemp to each enqueued item
  def push(queue, item)
    item['analytics_timestamp'] = Time.now if item.is_a?(Hash) && !Resque::Plugins::Analytics.ignore_classes.include?(item[:class])
    redis.pipelined do
      watch_queue(queue)
      redis.rpush "queue:#{queue}", encode(item)
    end
  end

  class Job
    # Override Job initialization to extract the timestamp
    def initialize(queue, payload)
      timestamp = payload.delete('analytics_timestamp')
      @queue = queue
      @payload = payload
      @failure_hooks_ran = false
      payload_class.send(:analytics_timestamp, timestamp) if timestamp && payload_class.respond_to?(:analytics_timestamp)
    end
  end

  module Plugins
    module Analytics

      FAILED = "failed"
      PERFORMED = "performed"
      TOTAL_TIME = "total_time"
      WAIT_TIME = "wait_time"

      EXPIRE = 90 * 24 * 60

      def self.ignore_classes=(class_array)
        @ignore_classes = class_array
      end

      def self.ignore_classes
        @ignore_classes || []
      end

      def key(kpi)
        date = Time.now.strftime("%y_%m_%d")
        "analytics:#{kpi}:#{self.name}:#{date}"
      end

      def around_perform_analytics(*args)
        start = Time.now
        yield
        total_time = Time.now - start

        Resque.redis.lpush(key(TOTAL_TIME), total_time)
        Resque.redis.expire(key(WAIT_TIME), EXPIRE)
      end

      def after_perform_analytics(*args)
        Resque.redis.incr(key(PERFORMED))
        Resque.redis.expire(key(WAIT_TIME), EXPIRE)
      end

      def on_failure_analytics(error, *args)
        Resque.redis.incr(key(FAILED))
        Resque.redis.expire(key(WAIT_TIME), EXPIRE)
      end

      def analytics_timestamp(timestamp)
        Resque.redis.lpush(key(WAIT_TIME), Time.now - Time.parse(timestamp))
        Resque.redis.expire(key(WAIT_TIME), EXPIRE)
      end

    end
  end
end