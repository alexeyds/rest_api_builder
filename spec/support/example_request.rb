require 'rest_api_builder'

module RestAPIBuilder
  class ExampleRequest
    include RestAPIBuilder

    def execute(options)
      handle_response do
        RestClient::Request.execute(compose_request_options(**options))
      end
    end

    def json_execute(options)
      handle_json_response do
        RestClient::Request.execute(compose_json_request_options(**options))
      end
    end
  end
end
