class Admin::ActionTypesController < ApplicationController
  layout 'admin'
  
  def index
    @action_types = ActionType.asc(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @action_types }
    end
  end

  def show
    @action_type = ActionType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @action_type }
    end
  end

  def new
    @action_type = ActionType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @action_type }
    end
  end

  def edit
    @action_type = ActionType.find(params[:id])
  end

  def create
    @action_type = ActionType.new(params[:action_type])

    respond_to do |format|
      if @action_type.save
        format.html { redirect_to admin_action_types_url, notice: 'Action type was successfully created.' }
        format.json { render json: @action_type, status: :created, location: @action_type }
      else
        format.html { render action: "new" }
        format.json { render json: @action_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @action_type = ActionType.find(params[:id])

    respond_to do |format|
      if @action_type.update_attributes(params[:action_type])
        format.html { redirect_to admin_action_types_url, notice: 'Action type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @action_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @action_type = ActionType.find(params[:id])
    @action_type.destroy

    respond_to do |format|
      format.html { redirect_to admin_action_types_url }
      format.json { head :no_content }
    end
  end
end
