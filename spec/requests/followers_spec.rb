require "rails_helper"

RSpec.describe "Followers", type: :request do
  before { OmniAuth.config.test_mode = true }
  after { OmniAuth.config.mock_auth[:keycloak] = nil }

  it "redirects visitors to the home page" do
    get followers_path

    expect(response).to redirect_to(root_path)
  end

  it "shows the message to signed in users" do
    OmniAuth.config.mock_auth[:keycloak] = OmniAuth::AuthHash.new(
      provider: "keycloak", uid: "1", info: { name: "Jane", email: "jane@example.com" }
    )

    get "/auth/keycloak/callback"
    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Signed in")
  end
end
