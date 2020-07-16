require 'webmock'
require 'rest_api_builder/url_helper'

module RestAPIBuilder
  class WebMockRequestExpectationsSingleton
    include WebMock::API
    include RestAPIBuilder::UrlHelper

    def expect_json_execute(response: nil, **options)
      if response && response[:body]
        response = response.merge(body: JSON.generate(response[:body]))
      end

      expect_execute(**options, response: response)
    end

    def expect_execute(base_url:, method:, path: nil, request: nil, response: nil)
      expectation = stub_request(method, full_url(base_url, path))

      expectation.with(request) if request
      expectation.to_return(response) if response

      expectation
    end
  end

  WebMockRequestExpectations = WebMockRequestExpectationsSingleton.new
end
