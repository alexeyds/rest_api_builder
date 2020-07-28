require 'rest-client'

module RestAPIBuilder
  class RequestSingleton
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

      response_handler = ResponseHandler.new
      execute_request = proc { RestClient::Request.execute(**options, log: logger, **rest_client_options) }

      if parse_json
        response_handler.handle_json_response(logger: logger, &execute_request)
      elsif raw_response
        response_handler.handle_response_error(&execute_request)
      else
        response_handler.handle_response(logger: logger, &execute_request)
      end
    end
  end

  Request = RequestSingleton.new
end
