module UsersHelper
	def individual_progress_bar_helper(campaign, user)
		number_to_percentage(100 * campaign.progress_by_individual(user))
	end

	def community_progress_bar_helper(campaign)
		number_to_percentage(100 * campaign.progress_by_community)
	end
end
