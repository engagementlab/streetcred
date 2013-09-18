class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def foursquare
    @user = Oauth.find_or_create_from_oauth(env['omniauth.auth'], 'foursquare', current_user)

    if @user.persisted?
      sign_in @user, :event => :authentication
      flash[:notice] = "Congratulations, your Foursquare account has been connected. Now check the campaigns page to learn where you can use."
      redirect_to edit_user_registration_path(current_user)
    else
      session["devise.foursquare_data"] = env["omniauth.auth"]
      redirect_to edit_user_registration_path(current_user)
    end
  end

  def instagram
    @user = Oauth.find_or_create_from_oauth(env['omniauth.auth'], 'instagram', current_user)

    if @user.persisted?
      sign_in @user, :event => :authentication
      flash[:notice] = "Congratulations, your Instagram account has been connected. Now check the campaigns page to learn where you can use."
      redirect_to participant_url(current_user)
    else
      session["devise.instagram_data"] = env["omniauth.auth"]
      redirect_to edit_user_registration_path(current_user)
    end

    id = ENV['INSTAGRAM_ID']
    secret = ENV['INSTAGRAM_SECRET']
    domain = ENV['DOMAIN']
    subscriptions = HTTParty.get("https://api.instagram.com/v1/subscriptions?client_id=#{id}&client_secret=#{secret}")
    if subscriptions['data'].empty?
      query = {
        :client_id => id,
        :client_secret => secret,
        :object => 'user',
        :aspect => 'media',
        :callback_url => "http://#{domain}/api/actions/instagram"
      }

      realtime = HTTParty.post('https://api.instagram.com/v1/subscriptions/', :body => query )
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
