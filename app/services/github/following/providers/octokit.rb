class Github::Following::Providers::Octokit < ServiceInterface
  private

  def run
    self.errors << "Access token and username are required" if kwargs[:access_token].blank? || kwargs[:username].blank?
    return if errors.any?

    client = ::Octokit::Client.new(access_token: kwargs[:access_token])
    self.result = client.unfollow(kwargs[:username])
    self.errors << "Could not unfollow #{kwargs[:username]}" unless result
  rescue ::Octokit::Error, Faraday::Error => e
    self.errors << "GitHub request failed: #{e.message}"
  end
end
