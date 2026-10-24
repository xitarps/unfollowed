OmniAuth.config.logger = Rails.logger

# Browser-facing URL (issuer) and container-to-container URL differ in Docker,
# so discovery is disabled and each endpoint is set explicitly.
issuer = ENV.fetch("OIDC_ISSUER", "http://localhost:8080/realms/unfollowed")
internal = ENV.fetch("OIDC_INTERNAL_URL", "http://keycloak:8080/realms/unfollowed")
app_url = ENV.fetch("APP_URL", "http://localhost:3000")

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :keycloak,
    scope: %i[openid profile email],
    response_type: :code,
    discovery: false,
    issuer: issuer,
    authorize_params: { kc_idp_hint: ENV["OIDC_IDP_HINT"].presence }.compact,
    client_options: {
      identifier: ENV.fetch("OIDC_CLIENT_ID", "unfollowed"),
      secret: ENV.fetch("OIDC_CLIENT_SECRET", "change-me"),
      redirect_uri: "#{app_url}/auth/keycloak/callback",
      authorization_endpoint: "#{issuer}/protocol/openid-connect/auth",
      token_endpoint: "#{internal}/protocol/openid-connect/token",
      userinfo_endpoint: "#{internal}/protocol/openid-connect/userinfo",
      jwks_uri: "#{internal}/protocol/openid-connect/certs"
    }
end
