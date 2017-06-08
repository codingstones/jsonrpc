# frozen_string_literal: true

RSpec::Matchers.define :be_a_jsonrpc_error do |klass|
  match do |actual|
    actual[:code] == klass.code && actual[:message] == klass.message
  end
end

RSpec::Matchers.define :have_id do |expected|
  match do |actual|
    actual[:id] == expected
  end
end
