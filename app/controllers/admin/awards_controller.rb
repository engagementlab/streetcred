class Admin::AwardsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_admin_user!
  
  def index
    @awards = Award.asc(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @awards }
    end
  end


  def new
    @award = Award.new
    # build a required action so the drop-down shows up in the form
    @award.required_actions.new

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
        format.html { redirect_to admin_awards_url, notice: 'Award was successfully created.' }
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
    @award.campaigns.clear if params[:award][:campaign_ids].blank?
    @award.required_actions.clear
    
    respond_to do |format|
      if @award.update_attributes(params[:award])
        format.html { redirect_to admin_awards_url, notice: 'Award was successfully updated.' }
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
      format.html { redirect_to admin_awards_url }
      format.json { head :no_content }
    end
  end
  
  def add_required_action
    respond_to do |format|
      format.json
    end
  end
end
