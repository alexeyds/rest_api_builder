require "spec_helper"
require "rest_api_builder"
require "./spec/support/example_request"
require "rest_api_builder/webmock_request_expectations"

describe "RestAPIBuilder README Examples" do
  let(:my_request) { RestAPIBuilder::ExampleRequest.new }

  describe "Usage" do
    before(:all) { WebMock.allow_net_connect! }
    after(:all) { WebMock.disable_net_connect! }

    it 'has simple request example' do
      response = my_request.execute(base_url: "api.github.com", method: :get)

      expect(response[:success]).to eq(true)
      expect(response[:status]).to eq(200)
      expect(response[:body]).not_to be_empty
      expect(response[:headers]).not_to be_empty
    end

    it 'has non-200 response example' do
      response = my_request.execute(base_url: "api.github.com", path: "/foo", method: :get)

      expect(response[:success]).to eq(false)
      expect(response[:status]).to eq(404)
      expect(response[:body]).not_to be_empty
    end

    it 'has json example' do
      response = my_request.json_execute(base_url: "api.github.com", path: "/users/octocat/orgs", method: :get)

      expect(response[:success]).to eq(true)
      expect(response[:body]).to be_a(Array)
    end
  end

  Expectations = RestAPIBuilder::WebMockRequestExpectations

  describe 'WebMock expectations' do
    it 'has simple expectation example' do
      Expectations.expect_execute(base_url: "test.com", method: :get)
      response = my_request.execute(base_url: "test.com", method: :get)

      expect(response[:success]).to eq(true)
      expect(response[:status]).to eq(200)
      expect(response[:body]).to eq('')
      expect(response[:headers]).to eq({})
    end

    it 'has response details example' do
      Expectations
        .expect_execute(base_url: "test.com", method: :get)
        .to_return(status: 404, body: "not found")
      response = my_request.execute(base_url: "test.com", method: :get)

      expect(response[:success]).to eq(false)
      expect(response[:status]).to eq(404)
      expect(response[:body]).to eq("not found")
    end

    it 'has :request/:response expectation details example' do
      Expectations.expect_execute(
        base_url: "test.com",
        method: :post,
        response: { body: 'hello' },
        request: { body: { foo: "bar" } } # body will be matched partially using hash_including matcher
      )

      response = my_request.json_execute(base_url: "test.com", method: :post, body: { foo: "bar", bar: "baz" })

      expect(response[:success]).to eq(true)
      expect(response[:body]).to eq('hello')
      expect do
        my_request.json_execute(base_url: "test.com", method: :post, body: { bar: "baz" })
      end.to raise_error(WebMock::NetConnectNotAllowedError)
    end

    it 'has #expect_json_execute example' do
      Expectations.expect_json_execute(
        base_url: "test.com",
        method: :get,
        response: { body: { hi: 'hello' } }
      )
      response = my_request.execute(base_url: "test.com", method: :get)
      expect(response[:success]).to eq(true)
      expect(response[:body]).to eq("{\"hi\":\"hello\"}")
    end
  end
end
