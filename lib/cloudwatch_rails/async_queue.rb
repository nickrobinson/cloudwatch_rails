require 'thread'
require 'cloudwatch_rails/cloudwatch_helper'
require 'cloudwatch_rails/config'
require 'byebug'

module CloudwatchRails
  class AsyncQueue
    attr_reader :consumer, :queue, :cloudwatch_helper

    def initialize
      @cloudwatch_helper = CloudwatchRails::CloudwatchHelper.new
      @queue = Queue.new
      @consumer = Thread.new do
        loop do
          msg = queue.pop

          method_name = msg.first
          args = msg.last

          Rails.logger.warn("Method: #{method_name} Args: #{args}")
          args[:metrics].each do |key, value|
            cloudwatch_helper.put_process_action_metric(args[:controller], args[:action], key, value)
          end

          # collector.__send__ method_name, *args
        end
      end
    end

    def push(msg)
      queue.push msg
    end

    def collector
      CloudwatchRails.collector
    end

  end
end