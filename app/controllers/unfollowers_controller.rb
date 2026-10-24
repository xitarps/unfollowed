class UnfollowersController < ApplicationController
  PER_PAGE = 20

  before_action :authenticate_user!

  def index
    return unless turbo_frame_request?

    service = Github::FetchUnfollowersService.call(
      access_token: github_token,
      cache_provider: Rails,
      cache_scope: current_user["uid"]
    )

    if service.errors.any?
      @users = Kaminari.paginate_array([]).page(1)
      Rails.logger.error("FetchUnfollowersService failed: #{service.errors.to_sentence}")
      @error = t("unfollowers.load_error")
    else
      @users = Kaminari.paginate_array(service.result).page(params[:page]).per(PER_PAGE)
    end

    render partial: "list"
  end

  def unfollow
    UnfollowUserJob.perform_later(JobsModules::GithubTokenCipher.encrypt(github_token), params[:id], current_user["uid"])
    redirect_to unfollowers_path(page: params[:page]), notice: t("unfollowers.notice.unfollow", login: params[:id])
  end

  def unfollow_all
    UnfollowAllJob.perform_later(JobsModules::GithubTokenCipher.encrypt(github_token), current_user["uid"])
    redirect_to unfollowers_path, notice: t("unfollowers.notice.unfollow_all")
  end

  private

  def github_token
    session[:github_token]
  end
end
