class API::UsersController < ApplicationController
  
  respond_to :json
  
  def index
    @users = User.asc(:first_name)
  end
  
  def show
    @user = User.find(params[:id])
  end

  def badge
    @user = User.find(params[:user_id])
    @campaign = Campaign.find(params[:campaign_id])
  end
end
