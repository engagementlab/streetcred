module UsersHelper
	def individual_progress_bar_helper(campaign, user)
		number_to_percentage(100 * campaign.progress_by_individual(user))
	end

	def community_progress_bar_helper(campaign)
		number_to_percentage(100 * campaign.progress_by_community)
	end

  def badge_api_path(user, campaign)
    "#{request.protocol}#{request.host_with_port}/api/users/#{user.id}/campaigns/#{campaign.id}/badge.json"
  end
end
