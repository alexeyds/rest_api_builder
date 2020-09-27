require 'forwardable'
require 'rest_api_builder/request/request_options'
require 'rest_api_builder/request/response_handler'

module RestAPIBuilder
  module Request
    extend Forwardable

    def_delegators RestAPIBuilder::Request::RequestOptions,
                   :compose_request_options,
                   :compose_json_request_options

    def_delegators RestAPIBuilder::Request::ResponseHandler,
                   :handle_response,
                   :handle_json_response,
                   :handle_response_error
  end
end
