class Github::FetchUnfollowersService < ServiceInterface
  CACHE_TTL = 5.minutes

  attr_reader :cached

  def self.cache_key(scope)
    [ "github", "unfollowers", scope ]
  end

  private

  def run
    self.errors << "Access token is required" if kwargs[:access_token].blank?
    return if errors.any?

    evaluate_cache
    return if @cached

    login = Github::Users::FetcherService.call(**kwargs.slice(:access_token), provider: kwargs[:users_provider] || Github::Users::FetcherService::DEFAULT_PROVIDER)
    self.errors += login.errors if login.errors.any?
    return if errors.any?

    following = fetch_relation(login.result, :following)
    followers = fetch_relation(login.result, :followers)
    return if errors.any?

    self.result = build_users(following - followers)
    write_cache
  end

  def fetch_relation(username, relation)
    data = Github::Relations::FetcherService.call(
      access_token: kwargs[:access_token],
      username: username,
      relation: relation,
      provider: kwargs[:relations_provider] || Github::Relations::FetcherService::DEFAULT_PROVIDER
    )
    self.errors += data.errors if data.errors.any?
    data.result || []
  end

  def build_users(logins)
    logins.map { |login| { login: login, avatar_url: "https://avatars.githubusercontent.com/#{login}" } }
  end

  def evaluate_cache
    return @cached = false if kwargs[:cache_provider].nil? || kwargs[:cache_scope].blank?

    cached_result = kwargs[:cache_provider].cache.read(self.class.cache_key(kwargs[:cache_scope]))
    return @cached = false if cached_result.nil?

    @cached = true
    self.result = cached_result
  end

  def write_cache
    return if kwargs[:cache_provider].nil? || kwargs[:cache_scope].blank?

    kwargs[:cache_provider].cache.write(self.class.cache_key(kwargs[:cache_scope]), result, expires_in: CACHE_TTL)
  end
end
