class Admin::AdminUsersController < ApplicationController
  layout 'admin'
  before_filter :authenticate_admin_user!
  
  def index
    @admin_users = AdminUser.asc(:email)
  end
end
