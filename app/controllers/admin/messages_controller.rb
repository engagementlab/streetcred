class Admin::MessagesController < ApplicationController
  layout 'admin'
  before_filter :authenticate_admin_user!
  
	def index
    @messages = Message.asc(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end


  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  def edit
    @message = Message.find(params[:id])
  end

  def create
    @message = Message.new(params[:message])

    respond_to do |format|
      if @message.save
        format.html { redirect_to admin_messages_url, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @message = Message.find(params[:id])
    @message.campaigns.delete_all
    
    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to admin_messages_url, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to admin_messages_url }
      format.json { head :no_content }
    end
  end
end
