require "spec_helper"
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

      expect(result[:success]).to eq(true)
      expect(result[:raw_response].code).to eq(200)
    end

    it 'handles non-200 responses' do
      stub_request(:get, 'test.com').to_return(body: 'hi', status: 404)
      result = handle_test_response

      expect(result[:success]).to eq(false)
      expect(result[:raw_response].code).to eq(404)
    end

    it 'throws if result has no response' do
      stub_request(:get, 'test.com').to_timeout

      expect do
        handle_test_response
      end.to raise_error(RestClient::Exceptions::OpenTimeout)
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

      expect(result[:success]).to eq(true)
      expect(result[:status]).to eq(200)
      expect(result[:body]).to eq('hi')
      expect(result[:headers][:x_test]).to eq('Foobar')
    end

    it 'logs response using provided :logger' do
      stub_request(:get, 'test.com')

      logger = spy('logger')
      handle_test_response(logger: logger)

      expect(logger).to have_received(:<<).with(String)
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

      expect(result[:success]).to eq(true)
      expect(result[:status]).to eq(200)
      expect(result[:body]).to eq('hi')
    end

    it 'parses response body as json' do
      stub_request(:get, 'test.com').to_return(body: "{\"a\":1}")
      result = handle_test_response

      expect(result[:body]).to eq({ "a" => 1 })
    end

    it 'returns body as is if it cannot be parsed as json' do
      stub_request(:get, 'test.com').to_return(body: "foo")
      result = handle_test_response

      expect(result[:body]).to eq("foo")
    end
  end
end
