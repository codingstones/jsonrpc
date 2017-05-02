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

RSpec::Matchers.define :be_a_method_not_found_error do
  match do |actual|
    actual[:code] == -32601 && actual[:message] == "Method not found"
  end
end

RSpec::Matchers.define :be_an_invalid_params_error do
  match do |actual|
    actual[:code] == -32602 && actual[:message] == "Invalid params"
  end
end

RSpec::Matchers.define :have_id do |expected|
  match do |actual|
    actual[:id] == expected
  end
end
