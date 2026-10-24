require "rails_helper"

RSpec.describe Github::UnfollowUserService do
  let(:ok) { class_double(ServiceInterface, call: instance_double(ServiceInterface, result: true, errors: [])) }
  let(:failing) { class_double(ServiceInterface, call: instance_double(ServiceInterface, result: nil, errors: [ "nope" ])) }

  it "requires token and username" do
    expect(described_class.call.errors).to include("Access token and username are required")
  end

  it "returns the username and clears the cache on success" do
    cache = ActiveSupport::Cache::MemoryStore.new
    cache.write(Github::FetchUnfollowersService.cache_key("u1"), [ 1 ])

    service = described_class.call(access_token: "t", username: "ann", provider: ok, cache_provider: double(cache: cache), cache_scope: "u1")

    expect(service.result).to eq("ann")
    expect(cache.read(Github::FetchUnfollowersService.cache_key("u1"))).to be_nil
  end

  it "reports provider errors" do
    service = described_class.call(access_token: "t", username: "ann", provider: failing)

    expect(service.errors).to include("nope")
    expect(service.result).to be_nil
  end
end
