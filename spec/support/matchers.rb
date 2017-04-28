RSpec::Matchers.define :be_an_invalid_json_error do
  match do |actual|
    actual[:code] == -32700 && actual[:message] == "Parse error"
  end
end

RSpec::Matchers.define :be_an_invalid_request_error do
  match do |actual|
    actual[:code] == -32600 && actual[:message] == "Invalid Request"
  end
end
