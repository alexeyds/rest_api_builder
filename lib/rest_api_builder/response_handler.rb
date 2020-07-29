require 'rest-client'

module RestAPIBuilder
  class ResponseHandler
    def handle_json_response(**options, &block)
      result = handle_response(**options, &block)
      result.merge(body: parse_json(result[:body]))
    end

    def handle_response(logger: nil, &block)
      result = parse_response(**handle_response_error(&block))
      maybe_log_result(result, logger: logger)
      result
    end

    def handle_response_error
      response = yield
      { raw_response: response, success: true }
    rescue RestClient::RequestFailed => e
      raise e unless e.response

      { raw_response: e.response, success: false }
    end

    private

    def parse_response(raw_response:, success:)
      {
        success: success,
        status: raw_response.code,
        body: raw_response.body,
        headers: raw_response.headers
      }
    end

    def maybe_log_result(result, logger:)
      logger && logger << "# => Response: #{result}\n"
    end

    def parse_json(json)
      JSON.parse(json)
    rescue JSON::ParserError
      json
    end
  end
end
