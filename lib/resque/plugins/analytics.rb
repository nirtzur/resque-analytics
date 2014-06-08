require 'resque'

module Resque
  module Plugins
    module Analytics

      FAILED = "failed"
      PERFORMED = "performed"
      TOTAL_TIME = "total_time"
      # WAIT_TIME = "wait_time"

      def key(kpi)
        date = Time.now.strftime("%y_%m_%d")
        "analytics:#{kpi}:#{self.name}:#{date}"
      end

      def around_perform_analytics(*args)
        start = Time.now
        yield
        total_time = Time.now - start

        Resque.redis.lpush(key(TOTAL_TIME), total_time)
        Resque.redis.expire(key(TOTAL_TIME), 90 * 24 * 60)
      end

      def after_perform_analytics(*args)
        Resque.redis.incr(key(PERFORMED))
        Resque.redis.expire(key(PERFORMED), 90 * 24 * 60)
      end

      def on_failure_analytics(e,*args)
        Resque.redis.incr(key(FAILED))
        Resque.redis.expire(key(FAILED), 90 * 24 * 60)
      end

    end
  end
end
