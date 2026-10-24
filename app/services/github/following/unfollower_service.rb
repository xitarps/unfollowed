class Github::Following::UnfollowerService < ServiceInterface
  DEFAULT_PROVIDER = Github::Following::Providers::Octokit

  private

  def run
    self.errors << "Access token and username cannot be blank" if kwargs[:access_token].blank? || kwargs[:username].blank?
    return if errors.any?

    data = (kwargs[:provider] || DEFAULT_PROVIDER).call(**kwargs.slice(:access_token, :username))
    self.result = data.result
    self.errors += data.errors if data.errors.any?
  end
end
