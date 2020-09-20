require "test_helper"
require "rest_api_builder"
require "./test/support/example_request"
require "rest_api_builder/webmock_request_expectations"

describe RestAPIBuilder::WebMockRequestExpectations do
  def request
    RestAPIBuilder::ExampleRequest.new
  end

  describe "#expect_request" do
    it 'defines basic expectation for request' do
      expectations.expect_execute(**get_test)
      result = request.execute(**get_test)

      assert_equal(true, result[:success])
      assert_equal(200, result[:status])
      assert_equal('', result[:body])
    end

    it 'returns expectation' do
      expectations.expect_execute(**get_test).to_return(body: 'hi')
      result = request.execute(**get_test)

      assert_equal('hi', result[:body])
    end

    it 'has :path parameter' do
      expectations.expect_execute(**get_test, path: '/orders')
      result = request.execute(**get_test, path: '/orders')

      assert_equal(true, result[:success])
    end

    it 'defines request expectations based on :request parameter' do
      expectations.expect_execute(**post_test, request: { body: 'hi' })

      assert_raises WebMock::NetConnectNotAllowedError do
        request.execute(**post_test)
      end
    end

    it 'defines response details based on :response paramter' do
      expectations.expect_execute(**get_test, response: { body: 'hi' })
      result = request.execute(**get_test)

      assert_equal('hi', result[:body])
    end

    it 'works if :request and response are empty hashes' do
      expectations.expect_execute(**get_test, request: {}, response: {})
      result = request.execute(**get_test)

      assert_equal('', result[:body])
    end

    it 'only partially matches expected body hash' do
      expectations.expect_execute(**post_test, request: { body: { a: '1' } })
      result = request.execute(**post_test, body: { a: 1, b: 2 })

      assert_equal(true, result[:success])
    end

    it 'only partially matches expected query hash' do
      expectations.expect_execute(**post_test, request: { query: { foo: 'bar' } })
      result = request.execute(**post_test, query: { foo: 'bar', b: 2 })

      assert_equal(true, result[:success])
    end

    it 'converts query values to string' do
      expectations.expect_execute(**get_test, request: { query: { foo: 1 } })
      result = request.execute(**get_test, query: { foo: 1 })

      assert_equal(true, result[:success])
    end

    it 'works if query/body are part of webmock API' do
      expectations.expect_execute(
        **post_test,
        request: { query: hash_including({ foo: 'bar' }), body: hash_including({ a: '1' }) }
      )
      result = request.execute(**post_test, query: { foo: 'bar' }, body: { a: 1 })

      assert_equal(true, result[:success])
    end

    it 'works with regex path' do
      expectations.expect_execute(**get_test, path: %r{/test/\d+})
      result = request.execute(**get_test, path: '/test/31')

      assert_equal(true, result[:success])
    end
  end

  describe '#expect_json_execute' do
    it 'behaves like #expect_execute' do
      expectations.expect_json_execute(**get_test)
      result = request.json_execute(**get_test)

      assert_equal(true, result[:success])
      assert_equal(200, result[:status])
      assert_equal('', result[:body])
    end

    it 'encodes response body' do
      expectations.expect_json_execute(**get_test, response: { body: { a: 1 } })
      result = request.json_execute(**get_test)

      assert_equal({ 'a' => 1 }, result[:body])
    end

    it 'does not modify response details' do
      expectations.expect_json_execute(**get_test, response: { body: { error: true }, status: 400 })
      result = request.json_execute(**get_test)

      assert_equal({ 'error' => true }, result[:body])
      assert_equal(400, result[:status])
    end

    it 'does nothing if response has no body' do
      expectations.expect_json_execute(**get_test, response: { status: 400 })
      result = request.json_execute(**get_test)

      assert_equal('', result[:body])
      assert_equal(400, result[:status])
    end
  end

  def get_test
    { base_url: 'test.com', method: :get }
  end

  def post_test
    { base_url: 'test.com', method: :post }
  end

  def expectations
    RestAPIBuilder::WebMockRequestExpectations
  end
end
