require "spec_helper"
require "rest_api_builder"
require "rest_api_builder/webmock_request_expectations"

RSpec.describe "RestAPIBuilder::WebMockRequestExpectations README" do
  include RestAPIBuilder::Request
  include RestAPIBuilder::WebMockRequestExpectations

  describe "#expect_execute" do
    it 'can be used with regular WebMock interface' do
      expect_execute(
        base_url: 'https://api.github.com',
        path: '/users/octocat/orgs',
        method: :post
      ).with(body: { foo: 'bar' }).to_return(body: '[hello]')

      response = RestClient::Request.execute(
        compose_request_options(
          base_url: 'https://api.github.com',
          path: '/users/octocat/orgs',
          method: :post,
          body: { foo: 'bar' }
        )
      )

      expect(response.body).to eq('[hello]')
    end

    it 'has response and request options' do
      expect_execute(
        base_url: 'https://api.github.com',
        path: '/users/octocat',
        method: :post,
        request: { body: { foo: 'bar' }, query: { a: 1, b: 2 } },
        response: { body: 'hello' }
      )

      response = RestClient::Request.execute(
        compose_request_options(
          base_url: 'https://api.github.com',
          path: '/users/octocat',
          method: :post,
          body: { foo: 'bar', bar: 'baz' },
          query: { a: 1, b: 2 }
        )
      )

      expect(response.body).to eq('hello')
    end
  end

  describe '#expect_json_execute' do
    it 'converts request.body to json' do
      expect_json_execute(
        base_url: 'https://api.github.com',
        path: '/users/octocat/orgs',
        method: :get,
        response: { body: { foo: 'bar' } }
      )

      response = RestClient::Request.execute(
        compose_request_options(
          base_url: 'https://api.github.com',
          path: '/users/octocat/orgs',
          method: :get
        )
      )

      expect(response.body).to eq("{\"foo\":\"bar\"}")
    end
  end
end
