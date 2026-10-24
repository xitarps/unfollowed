class Github::UnfollowUserService < ServiceInterface
  private

  def run
    self.errors << "Access token and username are required" if kwargs[:access_token].blank? || kwargs[:username].blank?
    return if errors.any?

    data = Github::Following::UnfollowerService.call(**kwargs.slice(:access_token, :username, :provider))
    self.errors += data.errors if data.errors.any?
    return if errors.any?

    clear_cache
    self.result = kwargs[:username]
  end

  def clear_cache
    return if kwargs[:cache_provider].nil? || kwargs[:cache_scope].blank?

    kwargs[:cache_provider].cache.delete(Github::FetchUnfollowersService.cache_key(kwargs[:cache_scope]))
  end
end
