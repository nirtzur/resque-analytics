require 'resque/server'

module Resque
  module Plugins
    module Analytics
      module Server
        VIEW_PATH = File.join(File.dirname(__FILE__), 'server', 'views')

        module Helpers
          def counters_for(job, kpi)
            kpi_keys = Resque.redis.keys("analytics:#{kpi}:#{job}:*").sort { |a,b| a <=> b }
            kpi_keys.inject({}) { |res, key| res[key.split(':').last] = key_value(key); res}
          end

          def measured_jobs
            Resque.redis.keys("analytics*").map { |key| key.split(':')[2] }.uniq
          end

          def key_value(key)
            if Resque.redis.type(key) == "string"
              Resque.redis.get(key)
            else
              Resque.redis.lrange(key, 0, -1).map(&:to_f).sum
            end
          end

          def legend_keys
            @legend_keys ||= (-90..0).map { |number| number.days.from_now.strftime("%y_%m_%d")}
          end

          def chart_data(data, job, kpi)
            legend_keys.map { |key| @data[job][kpi][key].to_i || 0 }
          end
        end

        class << self
          def registered(app)
            app.get '/analytics' do
              @data = measured_jobs.inject({}) { |res, job|
                res[job] = {}
                [PERFORMED, FAILED, TOTAL_TIME].each { |kpi| res[job][kpi] = counters_for(job, kpi) }
                res
              }
              erb(File.read(File.join(VIEW_PATH, 'analytics.erb')))
            end

            app.tabs << "Analytics"

            app.helpers(Helpers)
          end
        end
      end
    end
  end
end

Resque::Server.register Resque::Plugins::Analytics::Server
