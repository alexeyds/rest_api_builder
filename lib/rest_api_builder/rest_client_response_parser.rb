require 'json'

module RestAPIBuilder
  class RestClientResponseParser
    def initialize(logger:, parse_json:)
      @logger = logger
      @parse_json = parse_json
    end

    def parse_response(response, success:)
      @logger << "# => Response body: #{response.body}" if @logger
      body = @parse_json ? parse_json(response.body) : response.body
      { success: success, status: response.code, body: body, headers: response.headers }
    end

    private

    def parse_json(json)
      JSON.parse(json)
    rescue JSON::ParserError
      json
    end
  end
end
