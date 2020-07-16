require "test_helper"
require "rest_api_builder"
require "rest_api_builder/webmock_request_expectations"

describe "RestAPIBuilder README Examples" do
  Request = RestAPIBuilder::Request

  describe "Usage" do
    before { WebMock.allow_net_connect! }
    after { WebMock.disable_net_connect! }

    it 'has simple request example' do
      response = Request.execute(base_url: "example.com", method: :get)

      assert_equal true, response[:success]
      assert_equal 200, response[:status]
      refute_empty response[:body]
      refute_empty response[:headers]
    end

    it 'has non-200 response example' do
      response = Request.execute(base_url: "example.com", path: "/foo", method: :get)

      assert_equal false, response[:success]
      assert_equal 404, response[:status]
      refute_empty response[:body]
    end

    it 'has json example' do
      response = Request.json_execute(base_url: "api.github.com", path: "/users/octocat/orgs", method: :get)

      assert_equal true, response[:success]
      assert_kind_of Array, response[:body]
    end
  end

  Expectations = RestAPIBuilder::WebMockRequestExpectations
  describe 'WebMock expectations' do
    it 'has simple expectation example' do
      Expectations.expect_execute(base_url: "test.com", method: :get)
      response = Request.execute(base_url: "test.com", method: :get)

      assert_equal true, response[:success]
      assert_equal 200, response[:status]
      assert_equal '', response[:body]
      assert_equal({}, response[:headers])
    end

    it 'has response details example' do
      Expectations
        .expect_execute(base_url: "test.com", method: :get)
        .to_return(status: 404, body: "not found")
      response = Request.execute(base_url: "test.com", method: :get)

      assert_equal false, response[:success]
      assert_equal 404, response[:status]
      assert_equal "not found", response[:body]
    end

    it 'has :request/:response expectation details example' do
      Expectations.expect_execute(
        base_url: "test.com",
        method: :post,
        response: { body: 'hello' },
        request: { body: WebMock::API.hash_including({ foo: "bar" }) }
      )

      response = Request.json_execute(base_url: "test.com", method: :post, body: { foo: "bar" })

      assert_equal true, response[:success]
      assert_equal 'hello', response[:body]

      assert_raises WebMock::NetConnectNotAllowedError do
        Request.json_execute(base_url: "test.com", method: :post, body: { bar: "baz" })
      end
    end

    it 'has #expect_json_execute example' do
      Expectations.expect_json_execute(
        base_url: "test.com",
        method: :get,
        response: { body: { hi: 'hello' } }
      )
      response = Request.execute(base_url: "test.com", method: :get)
      assert_equal true, response[:success]
      assert_equal "{\"hi\":\"hello\"}", response[:body]
    end
  end
end
