class UnfollowUserJob < ApplicationJob
  queue_as :default

  def perform(encrypted_token, username, cache_scope)
    service = Github::UnfollowUserService.call(
      access_token: JobsModules::GithubTokenCipher.decrypt(encrypted_token),
      username: username,
      cache_provider: Rails,
      cache_scope: cache_scope
    )

    Rails.logger.error("UnfollowUserJob failed for #{username}: #{service.errors.join(', ')}") if service.errors.any?
  end
end
