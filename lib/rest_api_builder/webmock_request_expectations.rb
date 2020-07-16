require 'webmock'
require 'rest_api_builder/url_helper'

module RestAPIBuilder
  class WebMockRequestExpectationsSingleton
    include WebMock::API
    include RestAPIBuilder::UrlHelper

    def expect_execute(base_url:, method:, path: nil)
      stub_request(method, full_url(base_url, path))
    end
  end

  WebMockRequestExpectations = WebMockRequestExpectationsSingleton.new
end
