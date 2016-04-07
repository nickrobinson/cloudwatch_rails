require 'aws-sdk'
require 'cloudwatch_rails/config'

module CloudwatchRails
  class Railtie < Rails::Railtie
    # initializer 'cloudwatch_rails.test' do
    #   events = %w(process_action)
    #
    #   events.each do |name|
    #     ActiveSupport::Notifications.subscribe "#{name}.action_controller" do |*args|
    #       event = ActiveSupport::Notifications::Event.new(*args)
    #
    #       controller, action = event.payload.fetch(:controller), event.payload.fetch(:action)
    #
    #       Rails.logger.warn("action_controller.#{name}.#{controller}.#{action}: #{event.duration}")
    #     end
    #   end
    # end

    initializer 'cloudwatch_rails.subscribe_all' do

      CloudwatchRails.config = Config.new
      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, start, finish, id, payload|
        # borrows from
        # https://github.com/rails/rails/blob/3-0-stable/actionpack/lib/action_controller/log_subscriber.rb
        Thread.new {
          page_duration = (finish - start) * 1000
          #metrics_collected = Hash.new('metrics')
          metrics_collected = {'page_duration' => page_duration, 'view_runtime' => payload[:view_runtime], 'db_runtime' => payload[:db_runtime]}

          # Rails.logger.warn("Page Duration #{page_duration}")
          # Rails.logger.warn("Region: #{CloudwatchRails.config.config_hash[:region]}")
          Rails.logger.warn(payload)

          cloudwatch = Aws::CloudWatch::Client.new(region: CloudwatchRails.config.config_hash[:region])

          metrics_collected.each do |key, value|
            resp = cloudwatch.put_metric_data({
                                                  namespace: Rails.application.class.parent_name, # required
                                                  metric_data: [# required
                                                      {
                                                          metric_name: key, # required
                                                          dimensions: [
                                                              {
                                                                  name: payload[:controller], # required
                                                                  value: payload[:action], # required
                                                              }
                                                          ],
                                                          timestamp: Time.now,
                                                          value: value,
                                                          unit: 'Milliseconds', # accepts Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabytes, Gigabytes, Terabytes, Bits, Kilobits, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second, Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, None
                                                      },
                                                  ],
                                              })
          end
        }

      end
    end
  end
end