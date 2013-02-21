collection @users
attributes :first_name, :last_name, :email

child :actions do
  attributes :field, :case_id, :action_type, :description, :location, :lat, :lng, :created_at
end

child :awards do
  attributes :name, :occurrences, :message, :badge_url, :created_at
end