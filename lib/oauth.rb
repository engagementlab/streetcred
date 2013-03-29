module Oauth
  def self.find_or_create_from_facebook_oauth(data, signed_in_resource=nil)
    if User.find_by_provider_uid(data['uid']).present?
      return User.find_by_provider_uid(data['uid'])
    else
      if data['extra']['raw_info'] && data['extra']['raw_info']['location'] && data['extra']['raw_info']['location']['name']
        city = data['extra']['raw_info']['location']['name'].split(',').first.try(:strip)
        state = data['extra']['raw_info']['location']['name'].split(',').last.try(:strip)
      else 
        city = nil
        state = nil
      end
    
      user = User.new(:provider => 'facebook',
                      :provider_uid => data['uid'],
                      :provider_username => data['extra']['raw_info']['username'],
                      :name             => data['info']['name'],
                      :first_name       => data['info']['first_name'], 
                      :last_name        => data['info']['last_name'],
                      :email            => data['info']['email'],
                      :nickname         => data['info']['nickname'],
                      :city             => city,
                      :state            => state,
                      :password         => Devise.friendly_token[0,20] )
      user.save(:validate => false)
      return user
    end
  end

  # def self.find_or_create_from_facebook_oauth(data, signed_in_resource=nil)
  #   if User.find_by_provider_uid(data['uid']).present?
  #     return User.find_by_provider_uid(data['uid'])
  #   else
  #     if data['extra']['raw_info'] && data['extra']['raw_info']['location'] && data['extra']['raw_info']['location']['name']
  #       city = data['extra']['raw_info']['location']['name'].split(',').first.try(:strip)
  #       state = data['extra']['raw_info']['location']['name'].split(',').last.try(:strip)
  #     else 
  #       city = nil
  #       state = nil
  #     end
  #   
  #     user = User.new(:provider => 'facebook',
  #                     :provider_uid => data['uid'],
  #                     :provider_username => data['extra']['raw_info']['username'],
  #                     :name             => data['info']['name'],
  #                     :first_name       => data['info']['first_name'], 
  #                     :last_name        => data['info']['last_name'],
  #                     :email            => data['info']['email'],
  #                     :nickname         => data['info']['nickname'],
  #                     :city             => city,
  #                     :state            => state,
  #                     :password         => Devise.friendly_token[0,20] )
  #     user.save(:validate => false)
  #     return user
  #   end
  # end
  # 
  # def self.find_or_create_from_google_oauth(data, signed_in_resource=nil)
  #   if User.find_by_provider_and_provider_uid('google', data['uid']).present?
  #     return User.find_by_provider_and_provider_uid('google', data['uid'])
  #   else
  #     user = User.new(:provider => 'google',
  #                     :provider_uid => data['uid'],
  #                     :name => data['info'].try(:fetch, 'name'),
  #                     :first_name => data['info'].try(:fetch, 'first_name'), 
  #                     :last_name => data['info'].try(:fetch, 'last_name'), 
  #                     :email => data['info'].try(:fetch, 'email'), 
  #                     :password => Devise.friendly_token[0,20] )
  #     user.save(:validate => false)
  #     return user
  #   end
  # end
  # 
  # def self.find_or_create_from_twitter_oauth(data, signed_in_resource=nil)
  #   if User.find_by_provider_and_provider_uid('twitter', data['uid']).present?
  #     return User.find_by_provider_and_provider_uid('twitter', data['uid'])
  #   else
  #     if data['extra'].try(:fetch, 'raw_info').try(:fetch, 'location').present?
  #       location = data['extra']['raw_info']['location'].split(',')
  #     end
  #     user = User.new(:provider => 'twitter',
  #                     :provider_uid => data['uid'],
  #                     :provider_username => data['extra'].try(:fetch, 'raw_info').try(:fetch, 'screen_name'),
  #                     :name => data['extra'].try(:fetch, 'raw_info').try(:fetch, 'name'), 
  #                     :nickname => "@#{data['extra'].try(:fetch, 'raw_info').try(:fetch, 'screen_name')}",
  #                     :city => location.try(:first).try(:strip),
  #                     :state => location.try(:last).try(:strip),
  #                     :time_zone => data['extra'].try(:fetch, 'raw_info').try(:fetch, 'time_zone'),
  #                     :password => Devise.friendly_token[0,20] )
  #     user.save(:validate => false)
  #     return user
  #   end
  # end
end