module ApplicationHelper
  def progress_toward_campaign_helper(user, campaign, action)
    "#{user.matching_actions(campaign).count} out of #{campaign.required_occurrences_by_action(action)}"
  end
end
