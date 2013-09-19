class Admin::SessionsController < Devise::SessionsController
  layout 'admin'

	def after_sign_in_path_for(resource)
  	admin_campaigns_path
  end
end