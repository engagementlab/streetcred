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
    #@badges_earned = @campaign.users
    @actions_with_photos = @campaign.actions.or({:image_url.exists => true}, {:photo_url.exists => true}).desc(:created_at).limit(16)
    @actions_with_text = @campaign.actions.or({:body.exists => true}, {:subject.exists => true}).desc(:created_at).limit(5)
    @actions_recent = @campaign.actions.desc(:created_at).limit(5)
    
    gon.markers = @campaign.actions.all.reject {|x| x.latitude.blank? || x.longitude.blank?}.collect {|x| {type: 'Feature', geometry: {type: 'Point', coordinates: [x.longitude, x.latitude]}, properties: { title: x.user.try(:display_name), description: "#{x.action_type.try(:channel).try(:name)}<br />#{x.action_type.try(:name)}<br />#{ActionController::Base.helpers.link_to(x.created_at.strftime('%m/%d/%Y'), campaign_action_path(x.user, x))}", 'marker-size' => 'small', 'marker-color' => '#ff502d'}}}

    respond_with @campaign
  end
end
