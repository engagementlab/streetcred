class Users::OmniauthCallbacksController < ApplicationController
  def foursquare
    puts env['omniauth.auth']
    # @user = Oauth.find_or_create_from_google_oauth(env['omniauth.auth'], current_user)
    # 
    # if @user.persisted?
    #   sign_in @user, :event => :authentication
    #   redirect_logic
    # else
    #   session["devise.twitter_data"] = env["omniauth.auth"]
    #   redirect_to new_user_registration_url
    # end
  end
  
  # def facebook
  #   @user = Oauth.find_or_create_from_facebook_oauth(env["omniauth.auth"], current_user)
  #   if @user.persisted?
  #     sign_in @user, :event => :authentication
  #     redirect_logic
  #   else
  #     session["devise.facebook_data"] = env["omniauth.auth"]
  #     redirect_to new_user_registration_url
  #   end
  # end
  # 
  # def twitter
  #   @user = Oauth.find_or_create_from_twitter_oauth(env['omniauth.auth'], current_user)    
  # 
  #   if @user.persisted?
  #     sign_in @user, :event => :authentication
  #     redirect_logic
  #   else
  #     session["devise.twitter_data"] = env["omniauth.auth"]
  #     redirect_to new_user_registration_url
  #   end
  # end

  private

  def redirect_logic
    if @user.first_name.blank? || @user.last_name.blank? || @user.email.blank? || @user.date_of_birth.blank? || @user.gender.blank? || @user.notification_frequency.blank?
      flash[:notice] = "Welcome! Please complete your profile information"
      redirect_to edit_user_registration_path(@user)
    else
      flash[:notice] = "Welcome back, #{@user.first_name_or_screen_name}"
      redirect_to page_path('home')
    end
  end
end