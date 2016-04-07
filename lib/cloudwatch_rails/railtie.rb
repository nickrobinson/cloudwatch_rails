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
                  :page_duration => event.duration / 1000,
                  :view_runtime => event.payload[:view_runtime],
                  :db_runtime => event.payload[:db_runtime]
              }
          }
          CloudwatchRails.collector_config.queue.push [name, metrics_collected]
          # Rails.logger.warn("action_controller.#{name}.#{controller}.#{action}: #{event.duration}")
        end
      end
    end
  end
end