require "spec_helper"
require "rest_api_builder"

RSpec.describe "RestAPIBuilder::Request README", :http_request do
  include RestAPIBuilder::Request

  it 'has general usage example' do
    logger = spy('logger')
    response = handle_json_response(logger: logger) do
      RestClient::Request.execute(
        {
          **compose_json_request_options(
            base_url: 'https://api.github.com',
            path: '/users/octocat/orgs',
            method: :get
          ),
          log: logger
        }
      )
    end

    expect(response[:success]).to eq(true)
    expect(response[:status]).to eq(200)
    expect(response[:body]).to eq([])
    expect(logger).to have_received(:<<).with(String).exactly(3).times
  end

  describe "#handle_response" do
    it 'parses regular responses' do
      response = handle_response do
        RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
      end

      expect(response[:success]).to eq(true)
      expect(response[:status]).to eq(200)
      expect(response[:body]).to eq('[]')
      expect(response[:headers].keys).to include(:content_type)
    end

    it 'parses non-200 responses' do
      response = handle_response do
        RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/foo')
      end

      expect(response[:success]).to eq(false)
      expect(response[:status]).to eq(404)
      expect(response[:body]).to match(/Not Found/)
    end
  end

  describe "#handle_json_response" do
    it 'parses JSON response body' do
      response = handle_json_response do
        RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
      end

      expect(response[:success]).to eq(true)
      expect(response[:status]).to eq(200)
      expect(response[:body]).to eq([])
    end

    it "returns body as is if it's not a valid JSON object" do
      response = handle_json_response do
        RestClient::Request.execute(method: :get, url: 'https://github.com/foo/bar/test')
      end

      expect(response[:success]).to eq(false)
      expect(response[:status]).to eq(404)
      expect(response[:body]).to eq("Not Found")
    end
  end

  describe "#handle_response_error" do
    it 'returns RestClient::Response as :raw_response' do
      response = handle_response_error do
        RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
      end

      expect(response[:success]).to eq(true)
      expect(response[:raw_response]).to be_a(RestClient::Response)
    end

    it 'handles non-200 responses' do
      response = handle_response_error do
        RestClient::Request.execute(
          method: :get,
          url: 'https://api.github.com/users/octocat/foobar',
          raw_response: true
        )
      end

      expect(response[:success]).to eq(false)
      expect(response[:raw_response]).to be_a(RestClient::RawResponse)
    end
  end

  describe "#compose_request_options" do
    it 'has basic usage example' do
      response = RestClient::Request.execute(
        compose_request_options(
          base_url: 'https://api.github.com',
          path: '/users/octocat/orgs',
          method: :get
        )
      )

      expect(response.request.url).to eq("https://api.github.com/users/octocat/orgs")
      expect(response.body).to eq('[]')
    end

    it 'has advanced usage example' do
      result = handle_response_error do
        RestClient::Request.execute(
          compose_request_options(
            base_url: 'https://api.github.com',
            path: '/users/octocat/orgs',
            method: :post,
            body: 'Hello',
            headers: { content_type: 'foobar' },
            query: { foo: 'bar' }
          )
        )
      end
      request = result[:raw_response].request

      expect(request.url).to eq("https://api.github.com/users/octocat/orgs?foo=bar")
      expect(request.headers).to eq({ content_type: "foobar" })
    end
  end

  describe "#compose_json_request_options" do
    it 'converts body to json and adds content-type header' do
      result = handle_response_error do
        RestClient::Request.execute(
          compose_json_request_options(
            base_url: 'https://api.github.com',
            path: '/users/octocat/orgs',
            method: :post,
            body: { a: 1 }
          )
        )
      end
      request = result[:raw_response].request

      expect(request.headers).to eq({ content_type: :json })
      expect(request.payload.size).to eq(7)
    end
  end
end
