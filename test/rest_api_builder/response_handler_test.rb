require "test_helper"
require "rest_api_builder"

describe RestAPIBuilder::ResponseHandler do
  include RestAPIBuilder

  describe '#handle_response_error' do
    def handle_test_response
      handle_response_error do
        RestClient::Request.execute(method: :get, url: 'test.com')
      end
    end

    it 'returns raw response details' do
      stub_request(:get, 'test.com')
      result = handle_test_response

      assert_equal(true, result[:success])
      assert_equal(200, result[:raw_response].code)
    end

    it 'handles non-200 responses' do
      stub_request(:get, 'test.com').to_return(body: 'hi', status: 404)
      result = handle_test_response

      assert_equal(false, result[:success])
      assert_equal(404, result[:raw_response].code)
    end

    it 'throws if result has no response' do
      stub_request(:get, 'test.com').to_timeout

      assert_raises RestClient::Exceptions::OpenTimeout do
        handle_test_response
      end
    end
  end

  describe '#handle_response' do
    def handle_test_response(**options)
      handle_response(**options) do
        RestClient::Request.execute(method: :get, url: 'test.com')
      end
    end

    it 'extracts response details' do
      stub_request(:get, 'test.com').to_return(body: 'hi', headers: { 'X-Test': 'Foobar' })
      result = handle_test_response

      assert_equal(true, result[:success])
      assert_equal(200, result[:status])
      assert_equal('hi', result[:body])
      assert_equal('Foobar', result[:headers][:x_test])
    end

    it 'logs response using provided :logger' do
      stub_request(:get, 'test.com')

      logger = Minitest::Mock.new
      logger.expect(:<<, true, [String])
      handle_test_response(logger: logger)

      assert_mock logger
    end
  end

  describe "#handle_json_response" do
    def handle_test_response(**options)
      handle_json_response(**options) do
        RestClient::Request.execute(method: :get, url: 'test.com')
      end
    end

    it 'behaves like #handle_response' do
      stub_request(:get, 'test.com').to_return(body: 'hi')
      result = handle_test_response

      assert_equal(true, result[:success])
      assert_equal(200, result[:status])
      assert_equal('hi', result[:body])
    end

    it 'parses response body as json' do
      stub_request(:get, 'test.com').to_return(body: "{\"a\":1}")
      result = handle_test_response

      assert_equal({ "a" => 1 }, result[:body])
    end

    it 'returns body as is if it cannot be parsed as json' do
      stub_request(:get, 'test.com').to_return(body: "foo")
      result = handle_test_response

      assert_equal("foo", result[:body])
    end
  end
end
