class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def foursquare
    @user = Oauth.find_or_create_from_oauth(env['omniauth.auth'], 'foursquare', current_user)

    if @user.persisted?
      sign_in @user, :event => :authentication
      redirect_to user_url(current_user)
      # redirect_logic
    else
      session["devise.foursquare_data"] = env["omniauth.auth"]
      redirect_to user_url(current_user)
    end
  end

  def instagram
    @user = Oauth.find_or_create_from_oauth(env['omniauth.auth'], 'instagram', current_user)

    if @user.persisted?
      sign_in @user, :event => :authentication
      redirect_to user_url(current_user)
      # redirect_logic
    else
      session["devise.instagram_data"] = env["omniauth.auth"]
      redirect_to user_url(current_user)
    end
  end
  
  private

  # def redirect_logic
  #   if @user.first_name.blank? || @user.last_name.blank? || @user.email.blank? || @user.date_of_birth.blank? || @user.gender.blank? || @user.notification_frequency.blank?
  #     flash[:notice] = "Welcome! Please complete your profile information"
  #     redirect_to edit_user_registration_path(@user)
  #   else
  #     flash[:notice] = "Welcome back, #{@user.first_name_or_screen_name}"
  #     redirect_to page_path('home')
  #   end
  # end
end