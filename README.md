# RestAPIBuilder

A simple wrapper for rest-client aiming to make creation and testing of API clients easier.

## Why?
RestClient is great, but after building a few API clients with it you will almost inevitably find yourself re-implementing certain basic things such as:
- Compiling and parsing basic JSON requests/responses
- Handling and extracting details from non-200 responses
- Creating testing interfaces for your API clients

This library's tries to solve these and similar issues by providing a set of helper methods to improve on [rest-client](https://github.com/rest-client/rest-client) features and an optional [webmock](https://github.com/bblimke/webmock) testing interface for it.

## Installation
```
gem install rest_api_builder
```

## WebMock interface installation
Simply require webmock interface before your test, for example in your `test_helper.rb`:
```rb
  # test_helper.rb
  require "webmock"
  require "rest_api_builder/webmock_request_expectations"

  WebMock.enable!

  # my_spec.rb 
  require 'test_helper'

  describe 'my test' do
    it 'performs a request' do
      RestAPIBuilder::WebMockRequestExpectations.expect_execute(...).to_return(body: "hi!")
      result = RestClient::Request.execute(...)

      # some assertions
    end
  end
```

`RestAPIBuilder::WebMockRequestExpectations` expects that you have WebMock installed as a dependency.

## Usage
```rb
require "rest_api_builder"

class MyRequest
  include RestAPIBuilder

  def execute(options)
    handle_response do
      RestClient::Request.execute(compose_request_options(**options))
    end
  end

  def json_execute(options)
    handle_json_response do
      RestClient::Request.execute(compose_json_request_options(**options))
    end
  end
end

my_request = MyRequest.new

# Simple request:
response = my_request.execute(base_url: "example.com", method: :get)
response[:success] #=> true
response[:status]  #=> 200
response[:body]    #=> "<!doctype html>\n<html>..."
response[:headers] #=> {:accept_ranges=>"bytes", ...}

# Non-200 responses:
response = my_request.execute(base_url: "example.com", path: "/foo", method: :get)
response[:success] #=> false
response[:status]  #=> 404
response[:body]    #=> "<!doctype html>\n<html>..."

# JSON requests:
response = my_request.json_execute(base_url: "api.github.com", path: "/users/octocat/orgs", method: :get)
response[:success] #=> true
response[:body]    #=> []
```

## WebMock Expectations
```rb
require "rest_api_builder"
require "webmock"
require "rest_api_builder/webmock_request_expectations"

WebMock.disable_net_connect!

class MyRequest
  include RestAPIBuilder

  def execute(options)
    handle_response do
      RestClient::Request.execute(compose_request_options(**options))
    end
  end

  def json_execute(options)
    handle_json_response do
      RestClient::Request.execute(compose_json_request_options(**options))
    end
  end
end

my_request = MyRequest.new

Expectations = RestAPIBuilder::WebMockRequestExpectations

# Simple expectation
Expectations.expect_execute(base_url: "test.com", method: :get)
response = my_request.execute(base_url: "test.com", method: :get)

response[:success] #=> true
response[:status]  #=> 200
response[:body]    #=> ''
response[:headers] #=> {}

# Specifying expectation details with WebMock::Request methods
Expectations
  .expect_execute(base_url: "test.com", method: :get)
  .to_return(status: 404, body: "not found")
response = my_request.execute(base_url: "test.com", method: :get)

response[:success] #=> false
response[:status]  #=> 404
response[:body]    #=> "not found"

# Specifying expectation details with :request and :response options
Expectations.expect_execute(
  base_url: "test.com", 
  method: :post, 
  response: { body: 'hello' }, 
  request: { body: WebMock::API.hash_including({foo: "bar"}) }
)
response = my_request.json_execute(base_url: "test.com", method: :post, body: {foo: "bar"})
response[:success] #=> true
response[:body]    #=> 'hello'

my_request.json_execute(base_url: "test.com", method: :post, body: {bar: "baz"}) # => Raises WebMock::NetConnectNotAllowedError

# Using #expect_json_execute
Expectations.expect_json_execute(
  base_url: "test.com", 
  method: :get, 
  response: { body: {hi: 'hello'} }
)
response = my_request.execute(base_url: "test.com", method: :get)
response[:success] #=> true
response[:body]    #=> "{\"hi\":\"hello\"}"
```

## Request API
### RestAPIBuilder#compose_request_options(options)
Composes request options that can be passed to `RestClient::Request.execute`.
#### Options:
* **base_url**: Base URL of the request. Required.
* **method**: HTTP method of the request(e.g :get, :post, :patch). Required.
* **path**: Path to be appended to the :base_url. Optional.
* **body**: Request Body. Optional.
* **headers**: Request Headers. Optional.
* **query**: Query hash to be appended to the resulting url. Optional.

### RestAPIBuilder#compose_json_request_options(options)
Accepts same options as `compose_request_options` but will also:
- Add `Content-Type: 'application/json'` to request `headers`
- Convert request `body` to JSON if it's present

### RestAPIBuilder#handle_response(options, &block)
Executes given block, expecting to receive `RestClient::Response` as a result.\
Returns **plain ruby hash** with following keys: `:success`, `:status`, `:body`, `:headers`\
This will also gracefully handle non-200 responses, but will throw on any error without defined response(e.g server timeout)

#### Options:
* **logger**: A `Logger` instance. If provided, will log response details as RestClient wont do this by default. Optional

### RestAPIBuilder#handle_json_response(options, &block)
Same as `#handle_response` but will also attempt to decode response `:body`, returning it as is if a parsing error occurrs

### RestAPIBuilder#handle_response_error(options, &block)
Low-level API, you can use this method if you want to work with the RestClient's responses directly without any conversions(e.g when using `block_response` or `raw_response` options of RestClient). This will handle errors in the same way as `#handle_response` does, but will not do anything else.\
Returns ruby hash with `:success` and `:raw_response` keys.

## WebMockRequestExpectations API
### RestAPIBuilder::WebMockRequestExpectations.expect_execute(options)
Defines a request expectation using WebMock's `stub_request`. Returns an instance of `WebMock::RequestStub` on which methods such as `with`, `to_return`, `to_timeout` can be called

#### Options:
* **base_url**: Base URL of the request. Required.
* **method**: HTTP method of the request(e.g :get, :post, :patch). Required.
* **path**: Path to be appended to the :base_url. Optional.
* **request**: request details which will be passed to `WebMock::RequestStub#with` if provided. Optional
* **response**: response details which will be passed to `WebMock::RequestStub#to_return` if provided. Optional

### RestAPIBuilder::WebMockRequestExpectations.expect_json_execute(options)
A convenience shortcut for `#json_execute` which will convert `request[:body]` to JSON if it's present

## License
MIT