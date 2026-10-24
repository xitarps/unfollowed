require "rails_helper"

RSpec.describe "Unfollowers", type: :request do
  let(:users) { (1..25).map { |i| { login: "user#{i}", avatar_url: "https://avatars.githubusercontent.com/user#{i}" } } }

  def sign_in_user
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:keycloak] = OmniAuth::AuthHash.new(
      provider: "keycloak", uid: "1", info: { name: "Jane" }, credentials: { token: "kc-token", id_token: "id-token-123" }
    )
    token = instance_double(Github::Authentication::TokenFetcherService, errors: [], result: "gho_token")
    allow(Github::Authentication::TokenFetcherService).to receive(:call).and_return(token)
    get "/auth/keycloak/callback"
    expect(response).to redirect_to(unfollowers_path)
  end

  after { OmniAuth.config.mock_auth[:keycloak] = nil }

  let(:frame) { { "Turbo-Frame" => "unfollowers-list" } }

  it "is not public" do
    get unfollowers_path
    expect(response).to redirect_to(root_path)

    post unfollow_all_unfollowers_path
    expect(response).to redirect_to(root_path)
  end

  context "when signed in" do
    before do
      sign_in_user
      service = instance_double(Github::FetchUnfollowersService, errors: [], result: users)
      allow(Github::FetchUnfollowersService).to receive(:call).and_return(service)
    end

    it "renders a lazy skeleton frame on the full page request" do
      get unfollowers_path(page: 2)

      expect(response.body).to include("skeleton", "loading=\"lazy\"", "page=2")
      expect(response.body).not_to include("user21")
    end

    it "lists unfollowers with pagination and the unfollow all button" do
      get unfollowers_path, headers: frame

      expect(response.body).to include("user1", "Unfollow all (25)", "pagination")
      expect(response.body).to include('data-controller="loading-button"', "turbo:submit-start-&gt;loading-button#start")
      expect(response.body).not_to include("user21")

      get unfollowers_path(page: 2), headers: frame
      expect(response.body).to include("user21")
    end

    it "enqueues a job to unfollow a single account" do
      ActiveJob::Base.queue_adapter = :test

      expect { post unfollow_unfollower_path("user1") }.to have_enqueued_job(UnfollowUserJob)
        .with(satisfy { |token| JobsModules::GithubTokenCipher.decrypt(token) == "gho_token" }, "user1", "1")
            expect(response).to redirect_to(unfollowers_path(page: nil))
    end

    it "enqueues the unfollow all job" do
      ActiveJob::Base.queue_adapter = :test

      expect { post unfollow_all_unfollowers_path }.to have_enqueued_job(UnfollowAllJob)
      expect(response).to redirect_to(unfollowers_path)
    end

    it "signs out through Keycloak with the id_token_hint, skipping the confirmation page" do
      delete sign_out_path

      expect(response.location).to include("/protocol/openid-connect/logout", "id_token_hint=id-token-123")
      get unfollowers_path
      expect(response).to redirect_to(root_path)
    end
  end
end
