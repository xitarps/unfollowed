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
      @error = service.errors.to_sentence
    else
      @users = Kaminari.paginate_array(service.result).page(params[:page]).per(PER_PAGE)
    end

    render partial: "list"
  end

  def unfollow
    UnfollowUserJob.perform_later(JobsModules::GithubTokenCipher.encrypt(github_token), params[:id], current_user["uid"])
    redirect_to unfollowers_path(page: params[:page]), notice: "Unfollowing #{params[:id]}. The list will update in a moment."
  end

  def unfollow_all
    UnfollowAllJob.perform_later(JobsModules::GithubTokenCipher.encrypt(github_token), current_user["uid"])
    redirect_to unfollowers_path, notice: "Unfollowing everyone who doesn't follow you back. This may take a few minutes."
  end

  private

  def github_token
    session[:github_token]
  end
end
