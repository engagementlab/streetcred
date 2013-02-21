class Admin::AwardsController < ApplicationController
  layout 'admin'
  before_filter :load_campaign
  
  def index
    @awards = @campaign.awards.asc(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @awards }
    end
  end


  def new
    @award = Award.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @award }
    end
  end

  def edit
    @award = Award.find(params[:id])
  end

  def create
    @award = Award.new(params[:award])

    respond_to do |format|
      if @award.save
        format.html { redirect_to admin_campaign_awards_url(@campaign), notice: 'Award was successfully created.' }
        format.json { render json: @award, status: :created, location: @award }
      else
        format.html { render action: "new" }
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @award = Award.find(params[:id])
    @award.channels.clear if params[:award][:channel_ids].blank?
    @award.action_types.clear if params[:award][:action_type_ids].blank?
  
    respond_to do |format|
      if @award.update_attributes(params[:award])
        format.html { redirect_to admin_campaign_awards_url(@campaign), notice: 'Award was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @award = Award.find(params[:id])
    @award.destroy

    respond_to do |format|
      format.html { redirect_to admin_campaign_awards_url(@campaign) }
      format.json { head :no_content }
    end
  end
  
  private
  def load_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end
end
