require 'aws-sdk'
require 'cloudwatch_rails/config'
require 'byebug'

module CloudwatchRails
  class CloudwatchHelper

    def initialize(region= 'us-east-1')
      @client = Aws::CloudWatch::Client.new(region: region)
    end

    def put_process_action_metric(controller, action, name, value, unit = 'Milliseconds')
      resp = @client.put_metric_data({
          namespace: CloudwatchRails.config.metric_namespace, # required
          metric_data: [# required
              {
                  metric_name: name, # required
                  dimensions: [
                      {
                          name: controller, # required
                          value: action, # required
                      }
                  ],
                  timestamp: Time.now,
                  value: value,
                  unit: unit, # accepts Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabytes, Gigabytes, Terabytes, Bits, Kilobits, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second, Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, None
              },
          ],
      })
    end

  end
end