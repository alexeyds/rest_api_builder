require 'json'

module RestAPIBuilder
  class RestClientResponseParser
    def initialize(logger:, parse_json:, raw_response:)
      @logger = logger
      @parse_json = parse_json
      @raw_response = raw_response
    end

    def parse_response(response, success:)
      return { success: success, raw_response: response } if @raw_response

      body = @parse_json ? parse_json(response.body) : response.body

      result = {
        success: success,
        status: response.code,
        body: body,
        headers: response.headers
      }
      maybe_log_result(result)

      result
    end

    private

    def parse_json(json)
      JSON.parse(json)
    rescue JSON::ParserError
      json
    end

    def maybe_log_result(result)
      @logger && @logger << "# => Response: #{result}\n"
    end
  end
end
