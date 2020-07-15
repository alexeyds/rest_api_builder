require 'rest-client'
require 'rest_api_builder/url_helper'

module RestAPIBuilder
  class RequestSingleton
    include RestAPIBuilder::UrlHelper

    def execute(base_url:, method:, body: nil, headers: {}, query: nil, path: nil, logger: nil, rest_client_options: {})
      if method == :get && body
        raise ArgumentError, 'GET requests do not support body'
      end

      headers = headers.merge(params: query) if query

      begin
        response = RestClient::Request.execute(
          **rest_client_options,
          method: method,
          url: full_url(base_url, path),
          payload: body,
          headers: headers,
          log: logger
        )
        parse_response(response, success: true, logger: logger)
      rescue RestClient::RequestFailed => e
        raise e unless e.response

        parse_response(e.response, success: false, logger: logger)
      end
    end

    private

    def parse_response(response, success:, logger:)
      logger << "# => Response body: #{response.body}" if logger
      { success: success, status: response.code, body: response.body, headers: response.headers }
    end
  end

  Request = RequestSingleton.new
end
