module UsersHelper
	def progress_helper(campaign, user)
		number_to_percentage(100 * campaign.progress_by_individual(user))
	end
end
