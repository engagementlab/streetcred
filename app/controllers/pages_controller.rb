class PagesController < ApplicationController
	layout 'home'

	def index
		@current_campaign = Campaign.current
		gon.markers = Action.all.reject{|x| x.latitude.blank? || x.longitude.blank?}.collect {|x| {type: 'Feature', geometry: {type: 'Point', coordinates: [x.longitude, x.latitude]}, properties: { title: x.action_type.try(:channel).try(:name)), description: "#{x.action_type.try(:name)}<br />#{x.created_at.strftime('%m/%d/%Y')}", 'marker-size' => 'small', 'marker-color' => '#ff502d'}}}
	end
end
