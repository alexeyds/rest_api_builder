# RestAPIBuilder

A simple wrapper for rest-client aiming to make creation and testing of API clients easier.

## Why?
RestClient is great, but after building a few API clients with it you will almost inevitably find yourself re-implementing certain basic things such as:
- Compiling and parsing basic JSON requests/responses
- Handling and extracting details from non-200 responses
- Creating testing interfaces for your API clients

This library tries to solve these and similar issues by providing a set of self-contained helper methods to improve on [rest-client](https://github.com/rest-client/rest-client) features with an optional [WebMock](https://github.com/bblimke/webmock) testing interface.

## Installation
```
gem install rest_api_builder
```

## RestAPIBuilder::Request
Main RestAPIBuilder module which includes various helper methods for parsing RestClient responses, catching errors and composing request details. `handle_*` and `compose_*` methods are intended to be used in conjunction, but you can use any of them in any combination without relying on the rest.

```rb
# Basic usage
require 'rest_api_builder'
include RestAPIBuilder::Request

logger = Logger.new(STDOUT)
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

response[:success] # => true
response[:status]  # => 200
response[:body]    # => []
```

Included methods:

### `#handle_response(options, &block)`
Executes given block, expecting to receive RestClient::Response as a result.\
Returns plain ruby hash with following keys: `:success, :status, :body, :headers`\
This will gracefully handle non-200 responses, but will throw on any error without defined response(e.g server timeout)

```rb
require 'rest_api_builder'
include RestAPIBuilder::Request

# normal response
response = handle_response do
  RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
end

response[:success] # => true
response[:status]  # => 200
response[:body]    # => '[]'
response[:headers] # => {:accept_ranges=>"bytes", :access_control_allow_origin=>"*", ...}

# non-200 response that would result in RestClient::RequestFailed exception otherwise
response = handle_response do
  RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/foobar')
end

response[:success] # => false
response[:status]  # => 404
response[:body]    # => "{\"message\":\"Not Found\",..."}"
```

#### Accepted Options:
| Name   | Description |
|--------|-------------|
| logger | Any object with `<<` method, e.g `Logger` instance. Will be used to log *response* details in the same way that [RestClient's `log` option](https://github.com/rest-client/rest-client#logging) logs the request details. Optional |

### `#handle_json_response(options, &block)`
Behaves just like `#handle_response`, but will also attempt to decode response `:body`, returning it as is if a parsing error occurs.

```rb
require 'rest_api_builder'
include RestAPIBuilder::Request

# decodes JSON response body
response = handle_json_response do
  RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
end

response[:success] # => true
response[:status]  # => 200
response[:body]    # => []

# returns body as is if it cannot be decoded
response = handle_json_response do
  RestClient::Request.execute(method: :get, url: 'https://github.com/foo/bar/test')
end

response[:success] # => false
response[:status]  # => 404
response[:body]    # => "Not Found"
```

### `handle_response_error(&block)`
Low-level API.\
You can use this method if you want to work with regular `RestClient::Response` objects directly(e.g when using `block_response` or `raw_response` options). This will handle non-200 exceptions but will not do anything else.\
Returns plain ruby hash with `:success` and `:raw_response` keys.

```rb
require 'rest_api_builder'
include RestAPIBuilder::Request

# returns RestClient::Response as :raw_response
response = handle_response_error do
  RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
end

response[:success]      # => true
response[:raw_response] # => <RestClient::Response 200 "[]">

# handles non-200 responses
response = handle_response_error do
  RestClient::Request.execute(
    method: :get,
    url: 'https://api.github.com/users/octocat/foobar',
    raw_response: true
  )
end

response[:success]      # => false
response[:raw_response] # => <RestClient::RawResponse @code=404, @file=#<Tempfile...>>
```

### `#compose_request_options(options)`
Provides a more consistent interface for `RestClient::Request#execute`.\
This method returns a hash of options which you can then pass to `RestClient::Request#execute`.

```rb
require 'rest_api_builder'
include RestAPIBuilder::Request

# basic usage
response = RestClient::Request.execute(
  compose_request_options(
    base_url: 'https://api.github.com',
    path: '/users/octocat/orgs',
    method: :get
  )
)

response.request.url # => "https://api.github.com/users/octocat/orgs"
response.body        # => '[]'

# advanced options
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

request.url          # => "https://api.github.com/users/octocat/orgs?foo=bar"
request.headers      # => {:content_type=>"foobar"}
request.payload.size # => 5 
```

#### Accepted Options:
| Name     | Description |
|----------|-------------|
| base_url | Base URL of the request. Required. |
| method   | HTTP method of the request(e.g :get, :post, :patch). Required. |
| path     | Path to be appended to `base_url`. Optional. |
| body     | Request Body. Optional. |
| headers  | Request Headers. Optional. |
| query    | Query hash to be appended to the resulting url. Optional. |

### `#compose_json_request_options(options)`
Same as `compose_request_options` but will also convert provided `body`(if any) to JSON and append `Content-Type: 'application/json'` to `headers`

```rb
require 'rest_api_builder'
include RestAPIBuilder::Request

# basic usage
result = handle_response_error do
  RestClient::Request.execute(
    compose_json_request_options(
      base_url: 'https://api.github.com',
      path: '/users/octocat/orgs',
      method: :post,
      body: {a: 1}
    )
  )
end
request = result[:raw_response].request

request.headers      # => {:content_type=>:json}
request.payload.size # => 7
```

## RestAPIBuilder::APIClient

### `#define_resource_shortcuts(resources, resources_scope:, init_with:)`
Dynamically defines attribute readers for given resources

```rb
require 'rest_api_builder'

module ReadmeExamples
  module Resources
    class Octocat
      def orgs
        RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
      end
    end
  end

  class APIClient
    include RestAPIBuilder::APIClient

    def initialize
      define_resource_shortcuts(
        [:octocat],
        resources_scope: ReadmeExamples::Resources,
        init_with: ->(resource_class) { resource_class.new }
      )
    end
  end
end


GITHUB_API = ReadmeExamples::APIClient.new

response = GITHUB_API.octocat.orgs
response.body # => '[]'
response.code # => 200
```

#### Accepted Arguments:
| Name            | Description |
|-----------------|-------------|
| resources       | Array of resources to define shortcuts for |
| resources_scope | Module or String(path to Module) within which resource classes are contained |
| init_with       | Lambda which will be called for each resource class. The result will be returned from the defined shortcut. **Note:** `init_with` lambda is only called once so resource class must be able to function as a singleton. |

## RestAPIBuilder::WebMockRequestExpectations
Optional wrapper around WebMock mocking interface with various improvements. This module must be required explicitly and expects [WebMock](https://github.com/bblimke/webmock) to be installed as a dependency in your project.

### `#expect_execute(options)`
Defines a request expectation using WebMock's `stub_request`.
```rb
require 'rest_api_builder'
require 'rest_api_builder/webmock_request_expectations'
include RestAPIBuilder::Request
include RestAPIBuilder::WebMockRequestExpectations

# basic usage with regular webmock interface
expect_execute(
  base_url: 'https://api.github.com',
  path: '/users/octocat/orgs',
  method: :post
).with(body: {foo: 'bar'}).to_return(body: '[hello]')

response = RestClient::Request.execute(
  compose_request_options(
    base_url: 'https://api.github.com',
    path: '/users/octocat/orgs',
    method: :post,
    body: {foo: 'bar'}
  )
)

response.body # => '[hello]'

# using expect_execute's request and response options
expect_execute(
  base_url: 'https://api.github.com',
  path: '/users/octocat',
  method: :post,
  request: { body: {foo: 'bar'}, query: {a: 1, b: 2} }, # matches request body and query hashes partially by default
  response: { body: 'hello' }
)

response = RestClient::Request.execute(
  compose_request_options(
    base_url: 'https://api.github.com',
    path: '/users/octocat',
    method: :post,
    body: { foo: 'bar', bar: 'baz' }, 
    query: { a: 1, b: 2 }
  )
)

response.body # => 'hello'
```

#### Accepted Options:
| Name     | Description |
|----------|-------------|
| base_url | Base URL of the request expectation. Required. |
| path     | HTTP method of the request. Required. |
| method   | Path to be appended to `base_url`. Regular expressions are also supported. Optional. |
| request  | Hash of options which will be passed to WebMock's `with` methods with following changes: `body` hash is converted to `hash_including` expectation and `query` hash values are transformed to strings and then it's converted into `hash_including` expectation. Optional  |
| response | Hash of options which will be passed to WebMock's `to_return` method unchanged. Optional |

### `#expect_json_execute(options)`
Same as `expect_execute` but will also call JSON encode on `response.body`(if one is provided).

```rb
require 'rest_api_builder'
require 'rest_api_builder/webmock_request_expectations'
include RestAPIBuilder::Request
include RestAPIBuilder::WebMockRequestExpectations

expect_json_execute(
  base_url: 'https://api.github.com',
  path: '/users/octocat/orgs',
  method: :get,
  response: { body: { foo: 'bar' } }
)

response = RestClient::Request.execute(
  compose_request_options(
    base_url: 'https://api.github.com',
    path: '/users/octocat/orgs',
    method: :get
  )
)

response.body # => "{\"foo\":\"bar\"}"
```


## License
MIT
