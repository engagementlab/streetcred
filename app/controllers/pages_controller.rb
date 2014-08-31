class PagesController < ApplicationController
	layout 'home'

	def index
		@current_campaign = Campaign.current
		gon.markers = Action.all.reject {|x| x.latitude.blank? || x.longitude.blank? || !x.user.try(:claimed?) || !x.user.try(:shared?) || !x.user.try(:map_visible?)}.collect {|x| {type: 'Feature', geometry: {type: 'Point', coordinates: [x.longitude, x.latitude]}, properties: { title: x.user.try(:display_name), description: "#{x.action_type.try(:channel).try(:name)}<br />#{x.action_type.try(:name)}<br />#{formatted_date(x.created_at)}", 'marker-size' => 'small', 'marker-color' => '#ff502d'}}}
	end
end
