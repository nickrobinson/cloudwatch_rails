require 'spec_helper'
require 'cloudwatch_rails/config'

describe CloudwatchRails do
  it 'has a version number' do
    expect(CloudwatchRails::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(true).to eq(true)
  end

  it 'contains a config' do
    expect(CloudwatchRails::Config).not_to be nil
  end
end

class MockCloudwatchRailsConfig < CloudwatchRails::Config
  DEFAULT_CONFIG = {
      :debug => false,
      :region => 'us-east-1'
  }

  def initialize(initial_config={})
    @initial_config = initial_config
    @config_hash = DEFAULT_CONFIG.merge(initial_config)
    @initial_config = initial_config
  end
end

describe MockCloudwatchRailsConfig do
  it 'has an AWS region member function' do
    config = MockCloudwatchRailsConfig.new
    expect(config.aws_region).to eq('us-east-1')
  end

  it 'has ability to override AWS region' do
    config = MockCloudwatchRailsConfig.new(initial_config={region: 'us-west-1'})
    expect(config.aws_region).to eq('us-west-1')
  end
end
