class HomeController < ApplicationController
  def index
    redirect_to unfollowers_path if current_user
  end
end
