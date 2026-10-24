class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale

  helper_method :current_user

  private

  def switch_locale(&)
    locale = session[:locale].presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  def current_user
    session[:user]
  end

  def authenticate_user!
    redirect_to root_path, alert: t("flash.sign_in_required") unless current_user
  end
end
