object @user
attributes :first_name, :last_name, :email

child :actions do
  attributes :_id, :field, :case_id, :action_type, :description, :location, :lat, :lng
end

child :awards do
  attributes :_id, :badge_name, :badge_url
end