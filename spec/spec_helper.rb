# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_excluding http_request: true

  config.before(:example, http_request: true) do
    WebMock.allow_net_connect!
  end

  config.after(:example, http_request: true) do
    WebMock.disable_net_connect!
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!

  config.warnings = true

  config.order = :random

  Kernel.srand config.seed
end
