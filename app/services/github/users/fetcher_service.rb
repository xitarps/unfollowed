class Github::Users::FetcherService < ServiceInterface
  DEFAULT_PROVIDER = Github::Users::Providers::Octokit

  private

  def run
    self.errors << "Access token is required" if kwargs[:access_token].blank?
    return if errors.any?

    data = (kwargs[:provider] || DEFAULT_PROVIDER).call(**kwargs.slice(:access_token))
    self.result = data.result
    self.errors += data.errors if data.errors.any?
  end
end
