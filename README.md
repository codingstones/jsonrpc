# jsonrpc

[![Build Status](https://travis-ci.org/codingstones/jsonrpc.svg?branch=master)](https://travis-ci.org/codingstones/jsonrpc)

A Ruby implementation of [JSON-RPC 2.0](http://www.jsonrpc.org/specification). It's as simple as a parser and a response builder.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsonrpc', git: 'https://github.com/codingstones/jsonrpc'
```

And then execute:

    $ bundle

(We'll publish the gem to RubyGems soon).

## Usage

How to build a JSON-RPC request:

```ruby
require 'jsonrpc'

# First, we need a json with valid JSON-RPC format
p = {
    jsonrpc: '2.0',
    params: [1, 2],
    method: 'sum',
    id: 'foo'
}
request_body = JSON.generate(p)


# Let's parse it!
parser = JsonRPC::Parser.new
request = parser.parse(request_body)
request.invalid?  # false (validates the JSON-RPC format)
request.version   # 2.0
request.params    # [1, 2]
request.id        # 'foo'
request.method    # 'sum'
```

How to build a JSON-RPC response:

```ruby
response = JsonRPC::Response.new(request_id: 'foo', result: 3)
response.to_json # {:jsonrpc=>"2.0", :id=>"foo", :result=>3}
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codingstones/jsonrpc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/version/1/4/code-of-conduct/) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

