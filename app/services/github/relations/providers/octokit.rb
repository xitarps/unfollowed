class Github::Relations::Providers::Octokit < ServiceInterface
  RELATIONS = %i[following followers].freeze

  private

  def run
    self.errors << "Access token, username and a valid relation are required" unless valid?
    return if errors.any?

    client = ::Octokit::Client.new(access_token: kwargs[:access_token])
    client.auto_paginate = true
    self.result = client.public_send(kwargs[:relation], kwargs[:username]).map { |user| user[:login] }
  rescue ::Octokit::Error, Faraday::Error => e
    self.errors << "GitHub request failed: #{e.message}"
  end

  def valid?
    kwargs[:access_token].present? && kwargs[:username].present? && RELATIONS.include?(kwargs[:relation])
  end
end
