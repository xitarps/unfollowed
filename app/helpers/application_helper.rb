module ApplicationHelper
  # Cache key for static, translated fragments: busts on locale switch and when any locale file changes.
  def static_cache_key(name)
    [ *name, I18n.locale, locales_digest ]
  end

  private

  def locales_digest
    @@locales_digest ||= Digest::SHA256.hexdigest(
      Dir[Rails.root.join("config/locales/**/*.yml")].sort.map { |f| File.read(f) }.join
    )
  end
end
