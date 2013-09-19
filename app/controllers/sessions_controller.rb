class SessionsController < Devise::SessionsController

	def after_sign_in_path_for(resource)
  	participant_path(resource)
  end
end
