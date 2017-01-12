require 'resque'

module Resque
  # Override Resque's push method to add a timestemp to each enqueued item
  def push(queue, item)
    tries ||= 3
    item['analytics_timestamp'] = Time.now if item.is_a?(Hash) && !Resque::Plugins::Analytics.ignore_classes.include?(item[:class])
    redis.pipelined do
      watch_queue(queue)
      redis.rpush "queue:#{queue}", encode(item)
    end
  rescue Redis::TimeoutError, Redis::CannotConnectError
    retry if (tries -= 1).nonzero?
  end

  class Job
    # Override Job initialization to extract the timestamp
    def initialize(queue, payload)
      timestamp = payload && payload.delete('analytics_timestamp')
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

      EXPIRE = 90.days.to_i

      def self.ignore_classes=(class_array)
        @ignore_classes = class_array
      end

      def self.ignore_classes
        @ignore_classes || []
      end

      def key
        date = Time.now.strftime("%y_%m_%d")
        "resque-analytics:#{date}"
      end

      def field(kpi)
        "#{self.name}:#{kpi}"
      end

      def around_perform_analytics(*args)
        start = Time.now
        yield
        total_time = Time.now - start
        redis_command("hincrbyfloat", key, field(TOTAL_TIME), total_time)
      end

      def after_perform_analytics(*args)
        redis_command("hincrby", key, field(PERFORMED))
      end

      def on_failure_analytics(error, *args)
        redis_command("hincrby", key, field(FAILED))
      end

      def analytics_timestamp(timestamp)
        redis_command("hincrbyfloat", key, field(WAIT_TIME), Time.now - Time.parse(timestamp))
      end

      def redis_command(command, key, field, timestamp = 1)
        tries ||= 3
        Resque.redis.send(command, key, field, timestamp)
        Resque.redis.expire(key, EXPIRE)
      rescue Redis::TimeoutError, Redis::CannotConnectError
        retry if (tries -= 1).nonzero?
      end

    end
  end
end