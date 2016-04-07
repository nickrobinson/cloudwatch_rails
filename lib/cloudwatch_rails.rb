require "cloudwatch_rails/version"
require "cloudwatch_rails/railtie" if defined?(Rails)
require "cloudwatch_rails/config" if defined?(Rails)
require 'cloudwatch_rails/config' if defined?(Rails)

require 'byebug'

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
  end
end
