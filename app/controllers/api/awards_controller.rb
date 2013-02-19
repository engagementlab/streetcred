class Api::AwardsController < ApplicationController
  
  def index
    
  end
  
  def show
    @user = User.first
  end
end
