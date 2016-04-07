require 'cloudwatch_rails/version'
require 'cloudwatch_rails/railtie' if defined?(Rails)
require 'cloudwatch_rails/config'
require 'cloudwatch_rails/async_queue' if defined?(Rails)

module CloudwatchRails
  class CollectorConfig
    attr_accessor :collector, :queue
  end


  class << self
    attr_accessor :config

    def start
      unless @config
        @config = Config.new
      end
    end

    def transactions
      @transactions ||= {}
    end

    def collector_config
      @collector_config ||= CloudwatchRails::CollectorConfig.new
    end

    def config
      @config ||= CloudwatchRails::Config.new
    end
  end
end

CloudwatchRails.collector_config.queue = CloudwatchRails::AsyncQueue.new
