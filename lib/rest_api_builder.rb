require 'forwardable'
require 'rest_api_builder/request_options'
require 'rest_api_builder/response_handler'

module RestAPIBuilder
  class APIHelpers
    extend Forwardable

    def initialize
      @request_options = RequestOptions.new
      @response_handler = ResponseHandler.new
    end

    def_delegator :@request_options, :compose, :compose_request_options
    def_delegator :@request_options, :compose_json, :compose_json_request_options

    def_delegators :@response_handler, :handle_response, :handle_json_response, :handle_response_error
  end

  extend Forwardable

  def_delegators :rest_api_builder_helpers,
                 :compose_request_options,
                 :compose_json_request_options,
                 :handle_response,
                 :handle_json_response,
                 :handle_response_error

  def rest_api_builder_helpers
    APIHelpers.new
  end
end
