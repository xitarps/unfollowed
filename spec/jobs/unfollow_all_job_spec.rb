require "rails_helper"

RSpec.describe UnfollowAllJob do
  it "decrypts the token and runs the unfollow all service" do
    service = instance_double(Github::UnfollowAllService, errors: [], result: { unfollowed: [ "a" ], failed: [] })
    allow(Github::UnfollowAllService).to receive(:call).and_return(service)

    described_class.perform_now(JobsModules::GithubTokenCipher.encrypt("gho_secret"), "u1")

    expect(Github::UnfollowAllService).to have_received(:call).with(hash_including(access_token: "gho_secret", cache_scope: "u1"))
  end

  it "uses the sidekiq adapter" do
    expect(Rails.application.config.active_job.queue_adapter).to eq(:sidekiq)
  end
end
