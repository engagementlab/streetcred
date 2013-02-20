class Admin::AwardsController < ApplicationController
  layout 'admin'
  
  # GET /admin/awards
  # GET /admin/awards.json
  def index
    @awards = Award.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @awards }
    end
  end


  # GET /admin/awards/new
  # GET /admin/awards/new.json
  def new
    @award = Award.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @award }
    end
  end

  # GET /admin/awards/1/edit
  def edit
    @award = Award.find(params[:id])
  end

  # POST /admin/awards
  # POST /admin/awards.json
  def create
    @award = Award.new(params[:award])

    respond_to do |format|
      if @award.save
        params[:action_type_names].each do |action_type|
          @award.action_types.create(name: action_type)
        end
        format.html { redirect_to admin_awards_url, notice: 'Award was successfully created.' }
        format.json { render json: @award, status: :created, location: @award }
      else
        format.html { render action: "new" }
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/awards/1
  # PUT /admin/awards/1.json
  def update
    @award = Award.find(params[:id])
  
    respond_to do |format|
      if @award.update_attributes(params[:award])
        @award.action_types.clear
        params[:action_type_names].each do |action_type|
          @award.action_types.create(name: action_type)
        end
        format.html { redirect_to admin_awards_url, notice: 'Award was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @award.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/awards/1
  # DELETE /admin/awards/1.json
  def destroy
    @award = Award.find(params[:id])
    @award.destroy

    respond_to do |format|
      format.html { redirect_to admin_awards_url }
      format.json { head :no_content }
    end
  end
end
