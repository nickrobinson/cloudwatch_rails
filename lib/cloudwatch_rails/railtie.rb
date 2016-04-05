module CloudwatchRails
  class Railtie < Rails::Railtie
    initializer 'cloudwatch_rails.subscribe_all' do
      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, start, finish, id, payload|
        # borrows from
        # https://github.com/rails/rails/blob/3-0-stable/actionpack/lib/action_controller/log_subscriber.rb
        Thread.new {
          Rails.logger.warn(payload)

          cloudwatch = Aws::CloudWatch::Client.new(region: 'us-east-1')

          resp = cloudwatch.put_metric_data({
                                                namespace: 'Rails', # required
                                                metric_data: [# required
                                                    {
                                                        metric_name: payload[:controller], # required
                                                        dimensions: [
                                                            {
                                                                name: payload[:controller], # required
                                                                value: payload[:action], # required
                                                            }
                                                        ],
                                                        timestamp: Time.now,
                                                        statistic_values: {
                                                            sample_count: 1.0, # required
                                                            sum: payload[:view_runtime], # required
                                                            minimum: payload[:view_runtime], # required
                                                            maximum: payload[:view_runtime], # required
                                                        },
                                                        unit: "Milliseconds", # accepts Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabytes, Gigabytes, Terabytes, Bits, Kilobits, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second, Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, None
                                                    },
                                                ],
                                            })
        }

      end
    end
  end
end