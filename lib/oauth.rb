module Oauth
  
  def self.find_or_create_from_foursquare_oauth(data, signed_in_resource=nil)
    if User.where(provider: 'foursquare', provider_uid: data['uid']).first.present?
      user = User.where(provider: 'foursquare', provider_uid: data['uid']).first
      user.update_attributes( first_name: data['info']['first_name'], 
                              last_name: data['info']['last_name'],
                              email: data['info']['email'],
                              info: data['info'], 
                              credentials: data['credentials'], 
                              extra: data['extra']
                              )
      return user
    elsif User.where(email: data['info']['email']).first.present?
      user = User.where(email: data['info']['email']).first
      user.update_attributes( first_name: data['info']['first_name'], 
                              last_name: data['info']['last_name'],
                              provider: 'foursquare',
                              provider_uid: data['uid'],
                              info: data['info'], 
                              credentials: data['credentials'], 
                              extra: data['extra']
                              )
      return user
    else
      if data['info'] && data['info']['location']
        city = data['info']['location'].split(',').first.try(:strip)
        state = data['info']['location'].split(',').last.try(:strip)
      else 
        city = nil
        state = nil
      end
    
      user = User.new(:provider => 'facebook',
                      :provider_uid => data['uid'],
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