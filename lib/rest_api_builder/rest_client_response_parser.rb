require 'json'

module RestAPIBuilder
  class RestClientResponseParser
    def initialize(logger:, parse_json:)
      @logger = logger
      @parse_json = parse_json
    end

    def parse_response(response, success:)
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
