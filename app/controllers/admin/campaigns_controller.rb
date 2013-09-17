class Admin::CampaignsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_admin_user!
  
def index
    @campaigns = Campaign.asc(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @campaigns }
    end
  end


  def new
    @campaign = Campaign.new
    # build a required action so the drop-down shows up in the form
    @campaign.required_actions.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @campaign }
    end
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end

  def create
    @campaign = Campaign.new(params[:campaign])

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to admin_campaigns_url, notice: 'Campaign was successfully created.' }
        format.json { render json: @campaign, status: :created, location: @campaign }
      else
        format.html { render action: "new" }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.required_actions.clear
    
    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        format.html { redirect_to admin_campaigns_url, notice: 'Campaign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy

    respond_to do |format|
      format.html { redirect_to admin_campaigns_url }
      format.json { head :no_content }
    end
  end
  
  def add_required_action
    respond_to do |format|
      format.json
    end
  end
end
