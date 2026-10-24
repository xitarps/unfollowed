class Github::UnfollowAllService < ServiceInterface
  # Pause between requests to stay under GitHub's secondary rate limits for write actions.
  DEFAULT_DELAY = 1

  private

  def run
    self.errors << "Access token is required" if kwargs[:access_token].blank?
    return if errors.any?

    unfollowers = Github::FetchUnfollowersService.call(**kwargs.slice(:access_token, :users_provider, :relations_provider))
    self.errors += unfollowers.errors if unfollowers.errors.any?
    return if errors.any?

    self.result = unfollow(unfollowers.result.map { |user| user[:login] })
    clear_cache
  end

  def unfollow(logins)
    outcome = { unfollowed: [], failed: [] }

    logins.each do |login|
      data = Github::Following::UnfollowerService.call(**kwargs.slice(:access_token, :provider), username: login)
      (data.errors.any? ? outcome[:failed] : outcome[:unfollowed]) << login
      sleep(kwargs.fetch(:delay, DEFAULT_DELAY))
    end

    outcome
  end

  def clear_cache
    return if kwargs[:cache_provider].nil? || kwargs[:cache_scope].blank?

    kwargs[:cache_provider].cache.delete(Github::FetchUnfollowersService.cache_key(kwargs[:cache_scope]))
  end
end
