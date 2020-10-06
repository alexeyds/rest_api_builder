require 'forwardable'
require 'rest_api_builder/webmock_request_expectations/expectations'

module RestAPIBuilder
  module WebMockRequestExpectations
    extend Forwardable

    def_delegators Expectations, :expect_json_execute, :expect_execute
  end
end
