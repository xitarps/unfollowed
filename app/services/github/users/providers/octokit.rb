class Github::Users::Providers::Octokit < ServiceInterface
  private

  def run
    self.errors << "Access token is required" if kwargs[:access_token].blank?
    return if errors.any?

    self.result = ::Octokit::Client.new(access_token: kwargs[:access_token]).user[:login]
  rescue ::Octokit::Error, Faraday::Error => e
    self.errors << "GitHub request failed: #{e.message}"
  end
end
