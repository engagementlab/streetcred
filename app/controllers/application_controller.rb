class ApplicationController < ActionController::Base
  protect_from_forgery

	def after_sign_in_path_for(resource)
    if current_admin_user
       admin_campaigns_url
    else
      participant_path(resource)
    end
	end
end
