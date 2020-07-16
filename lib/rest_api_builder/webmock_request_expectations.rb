require 'webmock'
require 'rest_api_builder/url_helper'

module RestAPIBuilder
  class WebMockRequestExpectationsSingleton
    include WebMock::API
    include RestAPIBuilder::UrlHelper

    def expect_json_execute(response_body: nil, **options)
      response_body &&= JSON.generate(response_body)
      expect_execute(**options, response_body: response_body)
    end

    def expect_execute(
      base_url:,
      method:,
      status: 200,
      response_body: nil,
      response_headers: nil,
      request_body: nil,
      request_headers: nil,
      path: nil,
      query: nil,
      should_timeout: false
    )
      request = stub_request(method, full_url(base_url, path))

      add_request_expectations(request, { body: request_body, query: query, headers: request_headers })

      if should_timeout
        request.to_timeout
      else
        request.to_return(status: status, body: response_body, headers: response_headers)
      end
    end

    private

    def add_request_expectations(request, expectations)
      expectations = expectations.compact
      request.with(expectations) unless expectations.empty?
    end
  end

  WebMockRequestExpectations = WebMockRequestExpectationsSingleton.new
end
