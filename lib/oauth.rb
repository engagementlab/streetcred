module Oauth
  
  def self.find_or_create_from_oauth(data, provider_name, signed_in_resource=nil)
    provider = Provider.where(provider: provider_name, provider_uid: data['uid']).first
    user = User.where(email: data['info']['email']).first

    if provider.present? && provider.user.present?
      puts "*********** provider and provider.user present ***********"
      provider.update_attributes( info: data['info'], 
            credentials: data['credentials'], 
            extra: data['extra']
      )
      provider.user.update_attributes( first_name: data['info']['first_name'], 
            last_name: data['info']['last_name'],
            email: data['info']['email']
      )
      return provider.user


    elsif provider.blank? && signed_in_resource.present?
      puts "*********** current_user present and provider blank ***********"
      signed_in_resource.update_attributes( first_name: data['info']['first_name'], 
            last_name:  data['info']['last_name'],
            email:      data['info']['email'],
            nickname:   data['info']['nickname'],
      )
      signed_in_resource.providers.create( info: data['info'], 
            credentials:      data['credentials'], 
            extra:            data['extra'],
            provider_uid:     data['uid'],
            provider:         provider_name
      )
      return signed_in_resource

    elsif provider.blank? && user.present?
      puts "*********** user present and provider blank ***********"
      user.update_attributes( first_name: data['info']['first_name'], 
            last_name: data['info']['last_name'],
            email: data['info']['email']
      )
      user.providers.create( info: data['info'], 
            credentials:  data['credentials'], 
            extra:        data['extra'],
            provider_uid: data['uid'],
            provider:     provider_name
      )
      return user

    else provider.blank? && user.blank? && signed_in_resource.blank?
      puts "*********** provider blank and user blank and signed_in_resource blank ***********"
      if data['info'] && data['info']['location']
        city = data['info']['location'].split(',').first.try(:strip)
        state = data['info']['location'].split(',').last.try(:strip)
      else 
        city = nil
        state = nil
      end
      new_user = User.new(first_name:   data['info']['first_name'], 
                      last_name:        data['info']['last_name'],
                      email:            data['info']['email'],
                      nickname:         data['info']['nickname'],
                      city:             city,
                      state:            state,
                      password:         Devise.friendly_token[0,20] )
      new_user.save(:validate => false)
      new_user.providers.create(provider: provider_name,
                      provider_uid: data['uid'],
                      info: data['info'], 
                      credentials: data['credentials'], 
                      extra: data['extra']
      )
      return new_user
    end
  end

  # def self.find_or_create_from_instagram_oauth(data, signed_in_resource=nil)
  #   if User.where(provider: 'instagram', provider_uid: data['uid']).first.present?
  #     user = User.where(provider: 'instagram', provider_uid: data['uid']).first
  #     user.update_attributes( first_name: data['info']['first_name'], 
  #                             last_name: data['info']['last_name'],
  #                             email: data['info']['email'],
  #                             info: data['info'], 
  #                             credentials: data['credentials'], 
  #                             extra: data['extra']
  #                             )
  #     return user
  #   elsif User.where(email: data['info']['email']).first.present?
  #     user = User.where(email: data['info']['email']).first
  #     user.update_attributes( first_name: data['info']['first_name'], 
  #                             last_name: data['info']['last_name'],
  #                             provider: 'instagram',
  #                             provider_uid: data['uid'],
  #                             info: data['info'], 
  #                             credentials: data['credentials'], 
  #                             extra: data['extra']
  #                             )
  #     return user
  #   else
  #     if data['info'] && data['info']['location']
  #       city = data['info']['location'].split(',').first.try(:strip)
  #       state = data['info']['location'].split(',').last.try(:strip)
  #     else 
  #       city = nil
  #       state = nil
  #     end
    
  #     user = User.new(:provider => 'instagram',
  #                     :provider_uid => data['uid'],
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
end