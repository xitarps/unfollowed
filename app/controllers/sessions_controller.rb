class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    return redirect_to root_path, alert: t("flash.sign_in_failed") unless auth

    reset_session
    github_token = Github::Authentication::TokenFetcherService.call(access_token: auth.credentials&.token)
    return redirect_to root_path, alert: t("flash.token_failed") if github_token.errors.any?

    session[:github_token] = github_token.result
    session[:id_token] = auth.credentials&.id_token
    session[:user] = {
      "uid" => auth.uid,
      "name" => auth.info.name.presence || auth.info.nickname,
      "email" => auth.info.email
    }
    redirect_to unfollowers_path
  end

  def failure
    redirect_to root_path, alert: t("flash.sign_in_failed")
  end

  def destroy
    id_token = session[:id_token]
    reset_session
    redirect_to keycloak_logout_url(id_token), allow_other_host: true
  end

  private

  # With id_token_hint Keycloak logs out without asking for confirmation.
  def keycloak_logout_url(id_token)
    query = {
      client_id: ENV.fetch("OIDC_CLIENT_ID", "unfollowed"),
      post_logout_redirect_uri: root_url,
      id_token_hint: id_token
    }.compact.to_query
    "#{ENV.fetch('OIDC_ISSUER', 'http://localhost:8080/realms/unfollowed')}/protocol/openid-connect/logout?#{query}"
  end
end
