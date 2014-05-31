class ActionsController < ApplicationController
	respond_to :html

  def index
    if params[:participant_id].present?
      @participant = User.find(params[:participant_id])
      @actions = @participant.actions.all.desc(:created_at)
    else
      if params[:campaign_id].present?
        @campaign = Campaign.find(params[:campaign_id])
        @actions = @campaign.actions.all.desc(:created_at)
      end
    end
    
    respond_with @actions
  end

  def show
    @action = Action.find(params[:id])

    # Check if action has latitude/longitude to pass as parameters to load map
    if @action.latitude.present? && @action.longitude.present?
      gon.markers = [{type: 'Feature', geometry: {type: 'Point', coordinates: [@action.longitude, @action.latitude]}, properties: { title: @action.user.try(:display_name), description: "#{@action.action_type.try(:channel).try(:name)}<br />#{@action.action_type.try(:name)}<br />#{@action.created_at.strftime('%m/%d/%Y')}", 'marker-size' => 'small', 'marker-color' => '#ff502d'}}]
    end

    respond_with @action
  end
end
