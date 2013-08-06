class CampaignsController < ApplicationController
  def index
    @active_campaigns = Campaign.active
    @completed_campaigns = Campaign.completed
		@user = User.find(params[:user_id]) if params[:user_id].present?
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    @user = User.find(params[:id])
    @active_campaigns = Campaign.active
    @completed_campaigns = Campaign.completed

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
end
