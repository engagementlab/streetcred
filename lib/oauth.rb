module Oauth
  
  def self.find_or_create_from_foursquare_oauth(data, signed_in_resource=nil)
    if User.where(provider: 'foursquare', provider_uid: data['uid']).first.present?
      user = User.where(provider: 'foursquare', provider_uid: data['uid']).first
      user.update_attributes(info: data['info'], extras: data['extra'])
      return user
    elsif User.where(provider: 'foursquare', email: data['info']['email']).first.present?
      user = User.where(provider: 'foursquare', email: data['info']['email']).first
      user.update_attributes(info: data['info'], extras: data['extra'])
      return user
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
end