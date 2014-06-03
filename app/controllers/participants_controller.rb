class ParticipantsController < ApplicationController

  def index
    @participants = User.active.visible.sort_by {|x| x.actions.try(:count)}.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @participants }
    end
  end

  def show
    @participant = User.find(params[:id])
    @active_campaigns = Campaign.active
    @expired_contributed_to_campaigns = @participant.expired_contributed_to_campaigns
    @earned_awards = @participant.completed_campaigns.select {|x| x.requirements_met_by_individual?(@participant)}
    @actions_with_text = @participant.actions.or({:body.exists => true}, {:subject.exists => true}).desc(:created_at).limit(5)
    @actions_with_photos = @participant.actions.or({:image_url.exists => true}, {:photo_url.exists => true}).desc(:created_at).limit(16)
    @actions_recent = @participant.actions.desc(:created_at).limit(5)
    gon.markers = @participant.actions.all.reject {|x| x.latitude.blank? || x.longitude.blank?}.collect {|x| {type: 'Feature', geometry: {type: 'Point', coordinates: [x.longitude, x.latitude]}, properties: { title: x.user.try(:display_name), description: "#{x.action_type.try(:channel).try(:name)}<br />#{x.action_type.try(:name)}<br />#{ActionController::Base.helpers.link_to(x.created_at.strftime('%m/%d/%Y'), participant_action_path(x.user, x))}", 'marker-size' => 'small', 'marker-color' => '#ff502d', 'url' => "#{participant_action_path(x.user, x)}"}}}


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @participant }
    end
  end

  def search
    @participant = User.where(email: params[:email]).first_or_create # If user w/ that email doesn't exist yet, we create it
    
    # This condition will never happen anymore, as we are now using first_or_create to add a new user if it doesn't exist.
    #if @participant.blank?
    #  flash[:alert] = "We're sorry, but no profiles matched that email address. Please create a new account by sending an email to reports@streetcred.us and then claim your account, using the search form above."
    #  redirect_to new_user_session_path
    #end
  end
end
