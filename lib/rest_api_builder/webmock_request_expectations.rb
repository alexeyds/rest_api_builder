require 'rest_api_builder/webmock_request_expectations/expectations'

module RestAPIBuilder
  module WebMockRequestExpectations
    module_function

    def expect_json_execute(**options)
      Expectations.expect_json_execute(**options)
    end

    def expect_execute(**options)
      Expectations.expect_execute(**options)
    end
  end
end
