# RestAPIBuilder

A simple wrapper for rest-client aiming to make creation and testing of API clients easier.

## Why?
RestClient is great, but after building a few API clients with it you will almost inevitably find yourself re-implementing certain basic things such as:
- Compiling and parsing basic JSON requests/responses
- Handling and extracting details from non-200 responses
- Creating testing interfaces for your API clients

This library's tries to solve these and similar issues by providing a thin wrapper around [rest-client](https://github.com/rest-client/rest-client) and an optional [webmock](https://github.com/bblimke/webmock) testing interface for it.

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
      result = RestAPIBuilder::Request.execute(...)

      # some assertions
    end
  end
```

`RestAPIBuilder::WebMockRequestExpectations` expects that you have WebMock installed as a dependency.

## Usage
```rb
require "rest_api_builder"

Request = RestAPIBuilder::Request

# Simple request:
response = Request.execute(base_url: "example.com", method: :get)
response[:success] #=> true
response[:status]  #=> 200
response[:body]    #=> "<!doctype html>\n<html>..."
response[:headers] #=> {:accept_ranges=>"bytes", ...}

# Non-200 responses:
response = Request.execute(base_url: "example.com", path: "/foo", method: :get)
response[:success] #=> false
response[:status]  #=> 404
response[:body]    #=> "<!doctype html>\n<html>..."

# JSON requests:
response = Request.json_execute(base_url: "api.github.com", path: "/users/octocat/orgs", method: :get)
response[:success] #=> true
response[:body]    #=> []
```

## WebMock Expectations
```rb
require "rest_api_builder"
require "webmock"
require "rest_api_builder/webmock_request_expectations"

WebMock.disable_net_connect!

Request = RestAPIBuilder::Request
Expectations = RestAPIBuilder::WebMockRequestExpectations

# Simple expectation
Expectations.expect_execute(base_url: "test.com", method: :get)
response = Request.execute(base_url: "test.com", method: :get)

response[:success] #=> true
response[:status]  #=> 200
response[:body]    #=> ''
response[:headers] #=> {}

# Specifying response details
Expectations
  .expect_execute(base_url: "test.com", method: :get)
  .to_return(status: 404, body: "not found")
response = Request.execute(base_url: "test.com", method: :get)

response[:success] #=> false
response[:status]  #=> 404
response[:body]    #=> "not found"
```

## Request API
### RestAPIBuilder::Request.execute(options)
Performs a HTTP request via `RestClient::Request.execute`.\
Returns ruby hash with following keys: `:success`, `:status`, `:body`, `:headers`\
Does not throw on non-200 responses like RestClient does, but will throw on any error without defined response(e.g server timeout)

#### Options:
* **base_url**: Base URL of the request. Required.
* **method**: HTTP method of the request(e.g :get, :post, :patch). Required.
* **path**: Path to be appended to the :base_url. Optional.
* **body**: Request Body. Optional.
* **headers**: Request Headers. Optional.
* **query**: Query hash to be appended to the resulting url. Optional.
* **logger**: A `Logger` instance to be passed to RestClient in `log` option. Will also log response details as RestClient does not do this by default. Optional
* **parse_json**: Boolean. If `true`, will attempt to parse the response body as JSON. Will return the response body unchanged if it does not contain valid JSON. `false` by default.
* **rest_client_options**: Any additional options to be passed to `RestClient::Request.execute` unchanged. **Any option set here will completely overwrite all custom options**. For example, if you call `RestAPIBuilder::Request.execute(method: :post, rest_client_options: {method: :get})`, the resulting request will be sent as GET. Optional.

### RestAPIBuilder::Request.json_execute(options)
A convenience shortcut for `#execute` which will also:
- Add `Content-Type: 'application/json'` to request `headers`
- Convert request `body` to JSON
- Set `parse_json` option to `true`


## WebMockRequestExpectations API
### RestAPIBuilder::WebMockRequestExpectations.expect_execute(options)
Defines a request expectation using WebMock's `stub_request`. Returns an instance of `WebMock::RequestStub` on which methods such as `with`, `to_return`, `to_timeout` can be called

#### Options:
* **base_url**: Base URL of the request. Required.
* **method**: HTTP method of the request(e.g :get, :post, :patch). Required.
* **path**: Path to be appended to the :base_url. Optional.

## License
MIT