require 'yaml'
require 'erb'

module CloudwatchRails
  class Config
    DEFAULT_CONFIG = {
        :debug => false,
        :region => 'us-east-1'
    }

    attr_reader :env, :initial_config, :config_hash

    def initialize(initial_config={})
      @env = Rails.env.to_s
      @root_path = Rails.root.to_s
      # Initial config
      @config_hash = DEFAULT_CONFIG.merge(initial_config)
      @initial_config = initial_config

      # Load the config file if it exists
       if config_file && File.exists?(config_file)
         Rails.logger.warn(config_file)
         load_from_disk
       end
    end

    def merge(original_config, new_config)
      new_config.each do |key, value|
        unless original_config[key].nil?
          Rails.logger.warn("Config key '#{key}' is being overwritten")
        end
        original_config[key] = value
      end
    end

    def config_file
      @config_file ||=
          @root_path.nil? ? nil : File.join(@root_path, 'config', 'cloudwatch_rails.yml')
    end

    def load_from_disk
      configurations = YAML.load_file(config_file)
      config_for_this_env = configurations[env]
      if config_for_this_env
        config_for_this_env = Hash[config_for_this_env.map do |key, value|
          [key.to_sym, value]
        end] # convert keys to symbols

        merge(@config_hash, config_for_this_env)
      else
        @logger.error "Not loading from config file: config for '#{env}' not found"
      end
    end
  end
end