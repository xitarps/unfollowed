class Github::Authentication::Providers::KeycloakBroker < ServiceInterface
  private

  def run
    self.errors << "Keycloak access token is required" if kwargs[:access_token].blank?
    return if errors.any?

    response = request_token
    return if errors.any?

    token = extract_token(response.body)
    token.present? ? self.result = token : self.errors << "GitHub token not available in Keycloak"
  end

  def request_token
    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{kwargs[:access_token]}"
    request["Accept"] = "application/json"

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
      http.request(request)
    end

    self.errors << "Keycloak returned an error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    response
  rescue StandardError => e
    self.errors << "Keycloak connection failed: #{e.message}"
    nil
  end

  # Keycloak relays the GitHub payload, which is form-encoded unless GitHub is asked for JSON.
  def extract_token(body)
    JSON.parse(body)["access_token"]
  rescue JSON::ParserError
    URI.decode_www_form(body.to_s).to_h["access_token"]
  end

  def url
    kwargs[:url] || "#{ENV.fetch('OIDC_INTERNAL_URL', 'http://keycloak:8080/realms/unfollowed')}/broker/github/token"
  end
end
