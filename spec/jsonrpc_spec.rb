require "spec_helper"

RSpec.describe Jsonrpc do
  it "has a version number" do
    expect(Jsonrpc::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
