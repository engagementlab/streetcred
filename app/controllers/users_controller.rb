class UsersController < ApplicationController

  def index
    @users = User.all.sort_by {|x| x.actions.try(:count)}.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    @user = User.find(params[:id])
    @active_campaigns = Campaign.active
    @completed_campaigns = Campaign.completed
    @earned_campaigns = @completed_campaigns.select {|x| x.requirements_met_by_individual?(@user)}
    gon.markers = @user.actions.all.reject{|x| x.latitude.blank? || x.longitude.blank?}.collect {|x| {type: 'Feature', geometry: {type: 'Point', coordinates: [x.longitude, x.latitude]}, properties: { title: x.user.try(:display_name), description: "#{x.action_type.try(:channel).try(:name)}<br />#{x.action_type.try(:name)}<br />#{x.created_at.strftime('%m/%d/%Y')}", 'marker-size' => 'small', 'marker-color' => '#ff502d'}}}


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
end
