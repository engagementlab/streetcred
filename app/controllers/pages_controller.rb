class PagesController < ApplicationController
	layout 'home'

	def index
		@current_campaign = Campaign.active.last

		@json = Action.all.to_gmaps4rails do |action, marker|
			# marker.infowindow render_to_string(:partial => "/users/my_template", :locals => { :object => user})
			marker.picture({
										:picture => "/assets/marker.png",
										:width   => 28,
										:height  => 25
									 })
			# marker.title   "#{action.action_type.try(:name)}<br />#{action.created_at}"
			# marker.sidebar "i'm the sidebar"
			marker.json({ :id => action.id })
		end
	end
end
