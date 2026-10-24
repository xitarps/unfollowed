require "rails_helper"

RSpec.describe UnfollowUserJob do
  it "decrypts the token and unfollows the user" do
    service = instance_double(Github::UnfollowUserService, errors: [])
    allow(Github::UnfollowUserService).to receive(:call).and_return(service)

    described_class.perform_now(JobsModules::GithubTokenCipher.encrypt("gho_secret"), "bob", "u1")

    expect(Github::UnfollowUserService).to have_received(:call)
      .with(hash_including(access_token: "gho_secret", username: "bob", cache_scope: "u1"))
  end
end
