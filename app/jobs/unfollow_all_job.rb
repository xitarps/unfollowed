class UnfollowAllJob < ApplicationJob
  queue_as :default

  def perform(encrypted_token, cache_scope)
    service = Github::UnfollowAllService.call(
      access_token: JobsModules::GithubTokenCipher.decrypt(encrypted_token),
      cache_provider: Rails,
      cache_scope: cache_scope
    )

    if service.errors.any?
      Rails.logger.error("UnfollowAllJob failed: #{service.errors.join(', ')}")
    else
      Rails.logger.info("UnfollowAllJob finished: #{service.result[:unfollowed].size} unfollowed, #{service.result[:failed].size} failed")
    end
  end
end
