module Oauth
  
  def self.find_or_create_from_oauth(data, provider_name, signed_in_resource=nil)
    provider = Provider.where(provider: provider_name, provider_uid: data['uid']).first_or_create

    if signed_in_resource.present?
      signed_in_resource.update_attributes( first_name: data['info']['first_name']) if signed_in_resource.first_name.blank? 
      signed_in_resource.update_attributes( last_name: data['info']['last_name']) if signed_in_resource.last_name.blank? 
      signed_in_resource.update_attributes( email: data['info']['email']) if signed_in_resource.email.blank? 
      provider.update_attributes( info: data['info'], 
            credentials: data['credentials'], 
            extra: data['extra'],
            token: data['credentials']['token'],
            user_id: signed_in_resource.id
      )
      return signed_in_resource

    else # provider.blank? && user.blank? && signed_in_resource.blank?
      return nil
    end
  end
end
