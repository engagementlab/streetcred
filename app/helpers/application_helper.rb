module ApplicationHelper
  def progress_toward_campaign_helper(user, campaign, action)
    "#{user.matching_actions(campaign).count} out of #{campaign.required_individual_occurrences}"
  end
end
