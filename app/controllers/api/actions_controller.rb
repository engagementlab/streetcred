class Api::ActionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  respond_to :json
  
  def create
    if params['email'].present?
      user = User.find_or_create_by(email: params['email'])
      action = user.actions.create(params['action'])
      @awards = action.awards
      respond_with(@awards)
    end
    
  end
end
