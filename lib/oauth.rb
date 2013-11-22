module Oauth
  
  def self.find_or_create_from_oauth(data, provider_name, signed_in_resource=nil)
    provider = Provider.where(provider: provider_name, provider_uid: data['uid']).first
    # puts "*********************** searching for user with email address #{data['info']['email']}"
    # user = User.where(email: data['info']['email']).first
    # puts "*********************** user = #{user}"

    if provider.present? && provider.user.present?
      provider.update_attributes( info: data['info'], 
            credentials: data['credentials'], 
            extra: data['extra'],
            token: data['credentials']['token']
      )
      provider.user.update_attributes( first_name: data['info']['first_name'], 
            last_name: data['info']['last_name'],
            email: data['info']['email']
      )
      return provider.user

    elsif signed_in_resource.present? && provider.blank?
      signed_in_resource.update_attributes( first_name: data['info']['first_name']) if signed_in_resource.first_name.blank? 
      signed_in_resource.update_attributes( last_name: data['info']['last_name']) if signed_in_resource.last_name.blank? 
      signed_in_resource.update_attributes( email: data['info']['email']) if signed_in_resource.email.blank? 
      # signed_in_resource.update_attributes( nickname: data['info']['nickname']) if signed_in_resource.nickname.blank?
      signed_in_resource.providers.create( info: data['info'], 
            credentials:      data['credentials'], 
            extra:            data['extra'],
            provider_uid:     data['uid'],
            provider:         provider_name,
            token: data['credentials']['token']
      )
      return signed_in_resource

    # elsif user.present? && provider.blank?
    #   user.update_attributes( first_name: data['info']['first_name'], 
    #         last_name: data['info']['last_name']
    #   )
    #   user.providers.create( info: data['info'], 
    #         credentials:  data['credentials'], 
    #         extra:        data['extra'],
    #         provider_uid: data['uid'],
    #         provider:     provider_name,
    #         token: data['credentials']['token']
    #   )
    #   return user

    else # provider.blank? && user.blank? && signed_in_resource.blank?
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
                      extra: data['extra'],
                      token: data['credentials']['token']
      )
      return new_user
    end
  end
end
