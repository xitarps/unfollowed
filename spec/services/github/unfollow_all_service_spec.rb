require "rails_helper"

RSpec.describe Github::UnfollowAllService do
  let(:unfollowers) do
    instance_double(Github::FetchUnfollowersService, errors: [], result: [ { login: "ann" }, { login: "bob" } ])
  end
  let(:provider) do
    Class.new do
      def self.call(**kwargs)
        errors = kwargs[:username] == "bob" ? [ "failed" ] : []
        Struct.new(:result, :errors).new(errors.empty?, errors)
      end
    end
  end

  before { allow(Github::FetchUnfollowersService).to receive(:call).and_return(unfollowers) }

  it "requires an access token" do
    expect(described_class.call.errors).to include("Access token is required")
  end

  it "unfollows everyone and reports failures" do
    service = described_class.call(access_token: "t", provider: provider, delay: 0)

    expect(service.result).to eq(unfollowed: [ "ann" ], failed: [ "bob" ])
  end

  it "stops when the list cannot be fetched" do
    allow(unfollowers).to receive(:errors).and_return([ "boom" ])

    service = described_class.call(access_token: "t", provider: provider, delay: 0)

    expect(service.errors).to include("boom")
    expect(service.result).to be_nil
  end
end
