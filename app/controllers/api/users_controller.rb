class Api::UsersController < ApplicationController
  
  respond_to :json
  
  def index
    
  end
  
  def show
    @user = User.first
  end
end
