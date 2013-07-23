class API::UsersController < ApplicationController
  
  respond_to :json
  
  def index
    @users = User.asc(:first_name)
  end
  
  def show
    @user = User.find(params[:id])
  end
end
