class Github::Relations::FetcherService < ServiceInterface
  DEFAULT_PROVIDER = Github::Relations::Providers::Octokit

  private

  def run
    self.errors << "Access token, username and relation cannot be blank" if kwargs.values_at(:access_token, :username, :relation).any?(&:blank?)
    return if errors.any?

    data = (kwargs[:provider] || DEFAULT_PROVIDER).call(**kwargs.slice(:access_token, :username, :relation))
    self.result = data.result
    self.errors += data.errors if data.errors.any?
  end
end
