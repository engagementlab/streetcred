class Api::ActionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  respond_to :json
  
  def create
    # TODO need to respond to actions without an email
    if params['email'].present?
      user = User.find_or_create_by(email: params['email'])
      action = user.actions.create(params['action'])
      @earned_awards = user.awards_earned_by_action(action)
      NotificationMailer.status_email(user, action).deliver
      respond_with(@earned_awards)
    end
    
  end
end
