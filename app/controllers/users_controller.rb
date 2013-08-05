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
    @completed_earned_campaigns = @completed_campaigns.select {|x| x.requirements_met_by_individual?(@user)}
    @json = @user.actions.to_gmaps4rails

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
end
