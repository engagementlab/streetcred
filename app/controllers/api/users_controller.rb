class API::UsersController < ApplicationController
  
  respond_to :json
  
  def index
    @users = User.all.sort_by {|x| x.completed_campaigns.try(:count)}.reverse
  end
  
  def show
    @user = User.find(params[:id])
  end

  def badge
    @user = User.find(params[:user_id])
    @campaign = Campaign.find(params[:campaign_id])
  end
end
