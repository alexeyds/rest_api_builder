require 'rest_api_builder/request'
require 'rest_api_builder/request_options'

module RestAPIBuilder
  def compose_request_options(**options)
    RequestOptions.new.compose(**options)
  end

  def compose_json_request_options(**options)
    RequestOptions.new.compose_json(**options)
  end
end
