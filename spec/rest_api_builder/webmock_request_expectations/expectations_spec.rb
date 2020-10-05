require "spec_helper"
require "rest_api_builder"
require "rest_api_builder/webmock_request_expectations"

describe RestAPIBuilder::WebMockRequestExpectations::Expectations do
  include RestAPIBuilder::WebMockRequestExpectations

  let(:get_test) { { base_url: 'test.com', method: :get } }
  let(:post_test) { { base_url: 'test.com', method: :post } }

  include RestAPIBuilder::Request

  def execute(options)
    RestClient::Request.execute(compose_request_options(**options))
  end

  describe "#expect_request" do
    it 'defines basic expectation for request' do
      expect_execute(**get_test)
      response = execute(**get_test)

      expect(response.code).to eq(200)
      expect(response.body).to eq('')
    end

    it 'returns expectation' do
      expect_execute(**get_test).to_return(body: 'hi')
      response = execute(**get_test)

      expect(response.body).to eq('hi')
    end

    it 'has :path parameter' do
      expect_execute(**get_test, path: '/orders')
      response = execute(**get_test, path: '/orders')

      expect(response.code).to eq(200)
    end

    it 'defines request expectations based on :request parameter' do
      expect_execute(**post_test, request: { body: 'hi' })

      expect do
        execute(**post_test)
      end.to raise_error(WebMock::NetConnectNotAllowedError)
    end

    it 'defines response details based on :response paramter' do
      expect_execute(**get_test, response: { body: 'hi' })
      response = execute(**get_test)

      expect(response.body).to eq('hi')
    end

    it 'works if :request and response are empty hashes' do
      expect_execute(**get_test, request: {}, response: {})
      response = execute(**get_test)

      expect(response.body).to eq('')
    end

    it 'only partially matches expected body hash' do
      expect_execute(**post_test, request: { body: { a: '1' } })
      response = execute(**post_test, body: { a: 1, b: 2 })

      expect(response.code).to eq(200)
    end

    it 'only partially matches expected query hash' do
      expect_execute(**post_test, request: { query: { foo: 'bar' } })
      response = execute(**post_test, query: { foo: 'bar', b: 2 })

      expect(response.code).to eq(200)
    end

    it 'converts query values to string' do
      expect_execute(**get_test, request: { query: { foo: 1 } })
      response = execute(**get_test, query: { foo: 1 })

      expect(response.code).to eq(200)
    end

    it 'works if query/body are part of webmock API' do
      expect_execute(
        **post_test,
        request: { query: hash_including({ foo: 'bar' }), body: hash_including({ a: '1' }) }
      )
      response = execute(**post_test, query: { foo: 'bar' }, body: { a: 1 })

      expect(response.code).to eq(200)
    end

    it 'works with regex path' do
      expect_execute(**get_test, path: %r{/test/\d+})
      response = execute(**get_test, path: '/test/31')

      expect(response.code).to eq(200)
    end
  end

  describe '#expect_json_execute' do
    it 'behaves like #expect_execute' do
      expect_json_execute(**get_test)
      response = execute(**get_test)

      expect(response.code).to eq(200)
      expect(response.body).to eq('')
    end

    it 'encodes response body' do
      expect_json_execute(**get_test, response: { body: { a: 1 } })
      response = execute(**get_test)

      expect(response.body).to eq({ 'a' => 1 }.to_json)
    end

    it 'does not modify response details' do
      expect_json_execute(**get_test, response: { body: { created: true }, status: 202 })
      response = execute(**get_test)

      expect(response.body).to eq({ 'created' => true }.to_json)
      expect(response.code).to eq(202)
    end

    it 'does nothing if response has no body' do
      expect_json_execute(**get_test, response: { status: 204 })
      response = execute(**get_test)

      expect(response.body).to eq('')
      expect(response.code).to eq(204)
    end
  end
end
