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
end
