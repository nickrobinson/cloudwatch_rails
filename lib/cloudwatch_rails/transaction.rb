module CloudwatchRails
  class Transaction
    def self.create(key, env)
      Thread.current[:cloudwatch_rails_transaction_id] = key
      CloudwatchRails.transactions[key] = CloudwatchRails::Transaction.new(key, env)
    end

    def self.current
      CloudwatchRails.transactions[Thread.current[:cloudwatch_rails_transaction_id]]
    end

    attr_reader :id, :events, :exception, :env, :log_entry

    def initialize(id, env)
      @id = id
      @events = []
      @log_entry = nil
      @exception = nil
      @env = env
    end
  end
end