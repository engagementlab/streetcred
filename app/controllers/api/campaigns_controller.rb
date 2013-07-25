class API::CampaignsController < ApplicationController
	
	def index
    @campaigns = Campaign.asc(:name)
  end

  def show
  	@campaign = Campaign.find(params[:id])
  end

  def badge
    @campaign = Campaign.find(params[:id])
  end
end
