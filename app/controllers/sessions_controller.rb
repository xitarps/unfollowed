class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    return redirect_to root_path, alert: "Sign in failed" unless auth

    reset_session
    session[:user] = {
      "uid" => auth.uid,
      "name" => auth.info.name.presence || auth.info.nickname,
      "email" => auth.info.email
    }
    redirect_to followers_path
  end

  def failure
    redirect_to root_path, alert: "Sign in failed"
  end

  def destroy
    reset_session
    redirect_to keycloak_logout_url, allow_other_host: true
  end

  private

  def keycloak_logout_url
    query = {
      client_id: ENV.fetch("OIDC_CLIENT_ID", "unfollowed"),
      post_logout_redirect_uri: root_url
    }.to_query
    "#{ENV.fetch('OIDC_ISSUER', 'http://localhost:8080/realms/unfollowed')}/protocol/openid-connect/logout?#{query}"
  end
end
