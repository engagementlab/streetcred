class Admin::ActionsController < ApplicationController
  layout 'admin'
  
  # GET /admin/actions
  # GET /admin/actions.json
  def index
    @actions = Action.desc(:created_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @actions }
    end
  end

  # GET /admin/actions/new
  # GET /admin/actions/new.json
  def new
    @action = Action.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @action }
    end
  end

  # GET /admin/actions/1/edit
  def edit
    @action = Action.find(params[:id])
  end

  # POST /admin/actions
  # POST /admin/actions.json
  def create
    @action = Action.new(params[:action])

    respond_to do |format|
      if @action.save
        format.html { redirect_to admin_actions_url, notice: 'Action was successfully created.' }
        format.json { render json: @action, status: :created, location: @action }
      else
        format.html { render action: "new" }
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/actions/1
  # PUT /admin/actions/1.json
  def update
    @action = Action.find(params[:id])

    respond_to do |format|
      if @action.update_attributes(params[:action])
        format.html { redirect_to admin_actions_url, notice: 'Action was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/actions/1
  # DELETE /admin/actions/1.json
  def destroy
    @action = Action.find(params[:id])
    @action.destroy

    respond_to do |format|
      format.html { redirect_to admin_actions_url }
      format.json { head :no_content }
    end
  end
end
