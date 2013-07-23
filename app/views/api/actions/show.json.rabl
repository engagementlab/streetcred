object @action

attributes :_id, :api_key, :record_id, :case_id, :action_type, :description, :shared, :location, :latitude, :longitude, :coordinates, :address, :city, :zipcode, :state, :url, :photo_url, :created_at, :updated_at

child :user do
	attributes :_id, :first_name, :last_name, :email, :phone, :shared, :provider, :provider_uid, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :created_at, :updated_at
end

child :channel do
	attributes :_id, :name, :api_key
end

child :action_type do
	attributes :_id, :name, :provider_uid, :created_at, :updated_at
end