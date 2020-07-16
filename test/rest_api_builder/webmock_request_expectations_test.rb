require "test_helper"
require "rest_api_builder/webmock_request_expectations"

describe RestAPIBuilder::WebMockRequestExpectations do
  describe "#expect_request" do
    it 'defines basic expectation for request' do
      expectations.expect_execute(**get_test)
      result = request.execute(**get_test)

      assert_equal(true, result[:success])
      assert_equal(200, result[:status])
      assert_equal('', result[:body])
    end

    it 'has :status parameter' do
      expectations.expect_execute(**get_test, status: 404)
      result = request.execute(**get_test)

      assert_equal(404, result[:status])
    end

    it 'has :response_body parameter' do
      expectations.expect_execute(**get_test, response_body: 'hi')
      result = request.execute(**get_test)

      assert_equal('hi', result[:body])
    end

    it 'has response_headers parameter' do
      expectations.expect_execute(**get_test, response_headers: { 'X-Test' => true })
      result = request.execute(**get_test)

      assert_equal("true", result[:headers][:x_test])
    end

    it 'matches :request_body' do
      expectations.expect_execute(method: :post, base_url: 'test.com', request_body: 'hello')

      assert_raises WebMock::NetConnectNotAllowedError do
        request.execute(method: :post, base_url: 'test.com')
      end
    end

    it 'doesnt register body expectation if no :request_body is provided' do
      expectations.expect_execute(method: :post, base_url: 'test.com')
      result = request.execute(method: :post, base_url: 'test.com', body: 'hi')

      assert_equal(true, result[:success])
    end

    it 'has :path parameter' do
      expectations.expect_execute(**get_test, path: '/orders')
      result = request.execute(**get_test, path: '/orders')

      assert_equal(true, result[:success])
    end

    it 'has :query parameter' do
      expectations.expect_execute(**get_test, path: '/orders', query: { test: 1 })
      result = request.execute(**get_test, path: '/orders', query: { test: 1 })

      assert_equal(true, result[:success])
    end

    it 'matches :request_headers' do
      expectations.expect_execute(**get_test, request_headers: { 'X-Test' => true })

      assert_raises WebMock::NetConnectNotAllowedError do
        request.execute(**get_test)
      end
    end

    it 'has :should_timeout parameter' do
      expectations.expect_execute(**get_test, should_timeout: true)

      assert_raises RestClient::Exceptions::OpenTimeout do
        request.execute(**get_test)
      end
    end
  end

  def get_test
    { base_url: 'test.com', method: :get }
  end

  def request
    RestAPIBuilder::Request
  end

  def expectations
    RestAPIBuilder::WebMockRequestExpectations
  end
end
