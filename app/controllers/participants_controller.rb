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
    gon.markers = @participant.actions.all.reject {|x| x.latitude.blank? || x.longitude.blank?}.collect {|x| {type: 'Feature', geometry: {type: 'Point', coordinates: [x.longitude, x.latitude]}, properties: { title: x.user.try(:display_name), description: "#{x.action_type.try(:channel).try(:name)}<br />#{x.action_type.try(:name)}<br />#{x.created_at.strftime('%m/%d/%Y')}", 'marker-size' => 'small', 'marker-color' => '#ff502d'}}}


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @participant }
    end
  end

  def search
    @participant = User.where(email: params[:email]).first_or_create # If user w/ that email doesn't exist yet, we create it
    if @participant.blank?
      flash[:alert] = "We're sorry, but no profiles matched that email address. Please create a new account by sending an email to reports@streetcred.us and then claim your account, using the search form above."
      redirect_to new_user_session_path
    end
  end
end
