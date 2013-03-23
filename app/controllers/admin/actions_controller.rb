class Admin::ActionsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_admin_user!
  
  def index
    @actions = Action.desc(:created_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @actions }
    end
  end
  
  def show
    @action = Action.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @action }
    end
  end

  def new
    @action = Action.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @action }
    end
  end

  def edit
    @action = Action.find(params[:id])
  end

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

  def destroy
    @action = Action.find(params[:id])
    @action.destroy

    respond_to do |format|
      format.html { redirect_to admin_actions_url }
      format.json { head :no_content }
    end
  end
end
