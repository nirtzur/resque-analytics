require 'resque/server'
require 'resque/plugins/analytics'

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

          def chart_data(data, kpi)
            legend_keys.map { |key| @data[kpi][key].to_i || 0 }
          end

          def chart_it(title, legend, data)
            Gchart.bar(
              data: data,
              title: title,
              format: "image_tag",
              size: "1000x300",
              axis_with_labels: ['x,y'],
              bar_width_and_spacing: '6',
              axis_range: [[-90,0,-5], [0, data.map(&:max).sum ]],
              legend: legend,
              legend_position: 'top',
              bar_colors: ['000000', '0088FF']
            )
          end
        end

        class << self
          def registered(app)
            app.get '/analytics' do
              @job = params[:job] || measured_jobs.first

              @data = {}
              [PERFORMED, FAILED, TOTAL_TIME, WAIT_TIME].each { |kpi| @data[kpi] = counters_for(@job, kpi) }
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
