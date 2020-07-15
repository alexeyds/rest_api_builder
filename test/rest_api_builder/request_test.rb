require "test_helper"
require "rest_api_builder/request"

describe RestAPIBuilder::Request do
  describe "execute" do
    it "sends request to base_url and returns response info" do
      stub_request(:get, 'test.com').to_return(body: 'hi', headers: { 'X-Test' => 'yes' })
      result = request.execute(base_url: 'test.com', method: :get)

      assert_equal(true, result[:success])
      assert_equal(200, result[:status])
      assert_equal('hi', result[:body])
      assert_equal('yes', result[:headers][:x_test])
    end

    it "doesn't throw on non-200 responses" do
      stub_request(:get, 'test.com').to_return(status: 404)
      result = request.execute(base_url: 'test.com', method: :get)

      assert_equal(false, result[:success])
      assert_equal(404, result[:status])
    end

    it 'throws if result has no response' do
      stub_request(:get, 'test.com').to_timeout

      assert_raises RestClient::Exceptions::OpenTimeout do
        request.execute(base_url: 'test.com', method: :get)
      end
    end

    it 'has :path parameter' do
      stub_request(:get, 'test.com/orders')
      result = request.execute(base_url: 'test.com', path: '/orders', method: :get)

      assert_equal(true, result[:success])
    end

    it 'has :body parameter' do
      stub_request(:post, 'test.com').with(body: 'foo').to_return(body: 'bar')
      result = request.execute(base_url: 'test.com', method: :post, body: 'foo')

      assert_equal('bar', result[:body])
    end

    it 'raises if :body is passed to GET request' do
      assert_raises ArgumentError do
        request.execute(base_url: 'test.com', method: :get, body: 'foo')
      end
    end

    it 'has :headers parameter' do
      stub_request(:get, 'test.com').with(headers: { 'X-Test' => true }).to_return(body: 'tested')
      result = request.execute(base_url: 'test.com', method: :get, headers: { 'X-Test' => true })

      assert_equal('tested', result[:body])
    end

    it 'has :query parameter' do
      stub_request(:get, 'test.com?test=1').to_return(body: 'hi')
      result = request.execute(base_url: 'test.com', method: :get, query: { test: 1 })

      assert_equal('hi', result[:body])
    end

    it 'has :logger parameter' do
      logger = Minitest::Mock.new
      3.times { logger.expect(:<<, true, [String]) }

      stub_request(:get, 'test.com')
      request.execute(method: :get, base_url: 'test.com', logger: logger)

      assert_mock logger
    end

    it 'has :rest_client_options parameter' do
      stub_request(:get, 'test.com')
      request.execute(method: :get, base_url: 'test.com', rest_client_options: { timeout: 0, verify_ssl: false })
    end
  end

  def request
    RestAPIBuilder::Request
  end
end
