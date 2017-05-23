# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'jsonrpc'
require 'support/matchers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.order = 'random'
end
