class CampaignsController < ApplicationController
	respond_to :html

  def index
    @active_campaigns = Campaign.active
    @completed_campaigns = Campaign.completed
		@user = User.find(params[:user_id]) if params[:user_id].present?
    
    respond_with @active_campaigns
  end

  def show
    @campaign = Campaign.find(params[:id])
    @badges_earned = @campaign.users

    respond_with @campaign
  end
end
