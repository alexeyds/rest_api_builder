require 'forwardable'
require 'rest_api_builder/request'
require 'rest_api_builder/request_options'
require 'rest_api_builder/response_handler'

module RestAPIBuilder
  extend Forwardable

  def_delegator :request_options, :compose, :compose_request_options
  def_delegator :request_options, :compose_json, :compose_json_request_options

  def_delegators :response_handler, :handle_response, :handle_json_response, :handle_response_error

  def request_options
    RequestOptions.new
  end

  def response_handler
    ResponseHandler.new
  end
end
