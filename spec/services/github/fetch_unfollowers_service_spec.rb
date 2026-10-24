require "rails_helper"

RSpec.describe Github::FetchUnfollowersService do
  let(:users_provider) { class_double(ServiceInterface, call: instance_double(ServiceInterface, result: "me", errors: [])) }
  let(:relations_provider) do
    lambda do |relation|
      logins = relation == :following ? %w[ann bob cid] : %w[bob]
      instance_double(ServiceInterface, result: logins, errors: [])
    end
  end
  let(:provider) { Class.new { def self.call(**kwargs) = @handler.call(kwargs[:relation]); def self.handler=(h); @handler = h; end } }

  before { provider.handler = relations_provider }

  it "requires an access token" do
    service = described_class.call

    expect(service.errors).to include("Access token is required")
  end

  it "returns accounts followed that do not follow back" do
    service = described_class.call(access_token: "t", users_provider: users_provider, relations_provider: provider)

    expect(service.errors).to be_empty
    expect(service.result.map { |u| u[:login] }).to eq(%w[ann cid])
    expect(service.result.first[:avatar_url]).to eq("https://avatars.githubusercontent.com/ann")
  end

  it "propagates provider errors" do
    failing = class_double(ServiceInterface, call: instance_double(ServiceInterface, result: nil, errors: [ "boom" ]))

    service = described_class.call(access_token: "t", users_provider: failing, relations_provider: provider)

    expect(service.errors).to include("boom")
  end

  it "serves the cached result when available" do
    cache = ActiveSupport::Cache::MemoryStore.new
    cache_provider = double(cache: cache)
    cache.write(described_class.cache_key("u1"), [ { login: "cached" } ])

    service = described_class.call(access_token: "t", cache_provider: cache_provider, cache_scope: "u1")

    expect(service.cached).to be(true)
    expect(service.result).to eq([ { login: "cached" } ])
  end
end
