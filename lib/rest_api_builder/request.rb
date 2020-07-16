require 'rest-client'
require 'rest_api_builder/url_helper'
require 'rest_api_builder/rest_client_response_parser'

module RestAPIBuilder
  class RequestSingleton
    include RestAPIBuilder::UrlHelper

    def execute(
      base_url:,
      method:,
      body: nil,
      headers: {},
      query: nil,
      path: nil,
      logger: nil,
      parse_json: false,
      rest_client_options: {}
    )
      if method == :get && body
        raise ArgumentError, 'GET requests do not support body'
      end

      response_parser = RestAPIBuilder::RestClientResponseParser.new(logger: logger, parse_json: parse_json)
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
        response_parser.parse_response(response, success: true)
      rescue RestClient::RequestFailed => e
        raise e unless e.response

        response_parser.parse_response(e.response, success: false)
      end
    end
  end

  Request = RequestSingleton.new
end
