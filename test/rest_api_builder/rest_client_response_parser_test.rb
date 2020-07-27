require "test_helper"
require "rest_api_builder/rest_client_response_parser"

describe RestAPIBuilder::RestClientResponseParser do
  describe '#parse_response' do
    it 'extracts response details from RestClient::Response into plain hash' do
      response = build_response(body: 'hi', headers: { 'X-Test' => 'yes' })
      result = init_parser.parse_response(response, success: true)

      assert_equal(true, result[:success])
      assert_equal(200, result[:status])
      assert_equal('hi', result[:body])
      assert_equal('yes', result[:headers][:x_test])
    end

    it 'sets :success based on passed parameter' do
      result = init_parser.parse_response(build_response, success: false)

      assert_equal(false, result[:success])
    end

    it 'logs response details if :logger is provided' do
      logger = Minitest::Mock.new
      logger.expect(:<<, true, [String])
      parser = init_parser(logger: logger)
      parser.parse_response(build_response, success: true)

      assert_mock logger
    end

    it 'parses response body as json if :parse_json is true' do
      parser = init_parser(parse_json: true)
      result = parser.parse_response(build_response(body: "{\"a\":1}"), success: true)

      assert_equal({ "a" => 1 }, result[:body])
    end

    it 'returns body as is if it cannot be parsed as json' do
      parser = init_parser(parse_json: true)
      result = parser.parse_response(build_response(body: "foo"), success: true)

      assert_equal("foo", result[:body])
    end

    it 'returns raw response if :raw_response is true' do
      parser = init_parser(raw_response: true)
      result = parser.parse_response(build_response(body: "foo"), success: true)

      assert_equal(true, result[:success])
      refute_nil(result[:raw_response])
      refute_nil(result[:raw_response].headers)
    end
  end

  def build_response(body: nil, headers: nil)
    stub_request(:get, 'test.com').to_return(body: body, headers: headers)
    RestClient.get('test.com')
  end

  def init_parser(logger: nil, parse_json: false, raw_response: false)
    RestAPIBuilder::RestClientResponseParser.new(logger: logger, parse_json: parse_json, raw_response: raw_response)
  end
end
