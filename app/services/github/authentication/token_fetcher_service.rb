class Github::Authentication::TokenFetcherService < ServiceInterface
  DEFAULT_PROVIDER = Github::Authentication::Providers::KeycloakBroker

  private

  def run
    self.errors << "Access token is required" if kwargs[:access_token].blank?
    return if errors.any?

    data = (kwargs[:provider] || DEFAULT_PROVIDER).call(**kwargs.slice(:access_token, :url))
    self.result = data.result
    self.errors += data.errors if data.errors.any?
  end
end
