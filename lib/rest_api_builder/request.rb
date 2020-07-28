require 'rest-client'
require 'rest_api_builder/url_helper'
require 'rest_api_builder/rest_client_response_parser'

module RestAPIBuilder
  class RequestSingleton
    include RestAPIBuilder::UrlHelper

    def json_execute(headers: {}, body: nil, **options)
      headers = headers.merge(content_type: :json)
      body &&= JSON.generate(body)
      execute(**options, parse_json: true, headers: headers, body: body)
    end

    def execute(
      base_url:,
      method:,
      body: nil,
      headers: {},
      query: nil,
      path: nil,
      logger: nil,
      parse_json: false,
      raw_response: false,
      rest_client_options: {}
    )
      options = RequestOptions.new.compose(
        base_url: base_url,
        method: method,
        body: body,
        headers: headers,
        query: query,
        path: path
      )

      response_parser = RestAPIBuilder::RestClientResponseParser.new(
        logger: logger,
        parse_json: parse_json,
        raw_response: raw_response
      )

      begin
        response = RestClient::Request.execute(
          **options,
          log: logger,
          **rest_client_options
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
