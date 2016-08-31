class UsersController < ApplicationController
  def index
    @users = User.preload(:posts)
    render json: @users
  end
end
