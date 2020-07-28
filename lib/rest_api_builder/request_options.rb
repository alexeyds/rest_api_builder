require 'rest_api_builder/url_helper'

module RestAPIBuilder
  class RequestOptions
    include RestAPIBuilder::UrlHelper

    def compose(base_url:, method:, path: nil, body: nil, headers: {}, query: nil)
      if method == :get && body
        raise ArgumentError, 'GET requests do not support body'
      end

      headers = headers.merge(params: query) if query

      {
        method: method,
        url: full_url(base_url, path),
        payload: body,
        headers: headers
      }
    end

    def compose_json(**options)
      result = compose(**options)
      headers = result[:headers]
      payload = result[:payload]

      result.merge(
        headers: headers.merge(content_type: :json),
        payload: payload && JSON.generate(payload)
      )
    end
  end
end
