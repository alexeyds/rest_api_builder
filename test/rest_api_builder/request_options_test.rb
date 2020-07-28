require "test_helper"
require "rest_api_builder"

describe RestAPIBuilder::RequestOptions do
  include RestAPIBuilder

  describe '#compose' do
    def execute_request(**options)
      RestClient::Request.execute(compose_request_options(**options))
    end

    it 'builds request options for RestClient::Request.execute' do
      stub_request(:get, 'test.com')
      response = execute_request(base_url: 'test.com', method: :get)

      assert_equal(200, response.code)
    end

    it 'joins :base_url with :path' do
      stub_request(:get, 'test.com/test')
      response = execute_request(base_url: 'test.com', method: :get, path: '/test')

      assert_equal(200, response.code)
    end

    it 'has :body option' do
      stub_request(:post, 'test.com').with(body: 'foo')
      response = execute_request(base_url: 'test.com', method: :post, body: 'foo')

      assert_equal(200, response.code)
    end

    it 'raises if :body is passed to GET request' do
      assert_raises ArgumentError do
        execute_request(base_url: 'test.com', method: :get, body: 'foo')
      end
    end

    it 'has :headers option' do
      stub_request(:get, 'test.com').with(headers: { 'X-Test' => true })
      response = execute_request(base_url: 'test.com', method: :get, headers: { 'X-Test' => true })

      assert_equal(200, response.code)
    end

    it 'has :query option' do
      stub_request(:get, 'test.com?test=1')
      response = execute_request(base_url: 'test.com', method: :get, query: { test: 1 })

      assert_equal(200, response.code)
    end
  end

  describe '#compose_json' do
    def execute_request(**options)
      RestClient::Request.execute(compose_json_request_options(**options))
    end

    it 'behaves like #compose' do
      stub_request(:get, 'test.com')
      execute_request(base_url: 'test.com', method: :get)
    end

    it 'adds content-type header to request' do
      stub_request(:get, 'test.com')
        .with(headers: { 'Content-Type' => 'application/json' })
      response = execute_request(base_url: 'test.com', method: :get)

      assert_equal(200, response.code)
    end

    it 'respects other :headers' do
      stub_request(:get, 'test.com')
        .with(headers: { 'Content-Type' => 'application/json', 'X-Test' => true })
      response = execute_request(base_url: 'test.com', method: :get, headers: { 'X-Test' => true })

      assert_equal(200, response.code)
    end

    it 'converts :body to json' do
      stub_request(:post, 'test.com').with(body: "{\"a\":1}")
      response = execute_request(base_url: 'test.com', method: :post, body: { a: 1 })

      assert_equal(200, response.code)
    end

    it "doesn't encode nil bodies" do
      stub_request(:post, 'test.com').with(body: nil)
      response = execute_request(base_url: 'test.com', method: :post)

      assert_equal(200, response.code)
    end
  end
end
