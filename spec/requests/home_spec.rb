require "rails_helper"

RSpec.describe "Home", type: :request do
  it "renders the home page" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Welcome!")
  end

  it "redirects to the unfollowers list when signed in" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:keycloak] = OmniAuth::AuthHash.new(
      provider: "keycloak", uid: "1", info: { name: "Jane" }, credentials: { token: "kc-token", id_token: "id-token-123" }
    )
    token = instance_double(Github::Authentication::TokenFetcherService, errors: [], result: "gho_token")
    allow(Github::Authentication::TokenFetcherService).to receive(:call).and_return(token)
    get "/auth/keycloak/callback"

    get root_path

    expect(response).to redirect_to(unfollowers_path)
    OmniAuth.config.mock_auth[:keycloak] = nil
  end
end
