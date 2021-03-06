require 'aws-sdk'
require 'cloudwatch_rails/config'

module CloudwatchRails
  class Railtie < Rails::Railtie
    initializer 'cloudwatch_rails.test' do
      events = %w(process_action)

      events.each do |name|
        ActiveSupport::Notifications.subscribe "#{name}.action_controller" do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)

          metrics_collected = {
              :action => event.payload[:action],
              :controller => event.payload[:controller],
              :metrics => {
                  :page_duration => event.duration,
                  :view_runtime => event.payload[:view_runtime],
                  :db_runtime => event.payload[:db_runtime]
              }
          }
          CloudwatchRails.collector_config.queue.push [name, metrics_collected]
          # Rails.logger.warn("action_controller.#{name}.#{controller}.#{action}: #{event.duration}")
        end
      end
    end

    initializer 'cloudwatch_rails.sql' do
      ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Rails.logger.warn("Event: #{event.name} Duration: #{event.duration} Name: #{event.payload[:name]}")
      end
    end

    initializer 'cloudwatch_rails.custom' do
      if CloudwatchRails.config.custom_metrics
        ActiveSupport::Notifications.subscribe /cloudwatch_rails/ do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)

          metric = {name: event.name.split('.')[1], value: event.duration, unit: event.payload[:unit]}

          CloudwatchRails.collector_config.queue.push ['custom', metric]
        end
      end
    end
  end
end