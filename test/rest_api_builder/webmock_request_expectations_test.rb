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

    it 'has :path parameter' do
      expectations.expect_execute(**get_test, path: '/orders')
      result = request.execute(**get_test, path: '/orders')

      assert_equal(true, result[:success])
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
