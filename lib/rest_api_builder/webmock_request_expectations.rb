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
      url = path.is_a?(Regexp) ? /#{base_url}#{path}/ : full_url(base_url, path)
      expectation = stub_request(method, url)

      if !request.nil? && request.any?
        add_request_expectations(expectation, request)
      end

      expectation.to_return(response) if response

      expectation
    end

    def add_request_expectations(expectation, request)
      if request[:body].is_a?(Hash)
        request = request.merge(body: hash_including(request[:body]))
      end

      if request[:query].is_a?(Hash)
        query = request[:query].transform_values(&:to_s)
        request = request.merge(query: hash_including(query))
      end

      expectation.with(request)
    end
  end

  WebMockRequestExpectations = WebMockRequestExpectationsSingleton.new
end
