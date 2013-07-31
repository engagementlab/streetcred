module ApplicationHelper
  def progress_toward_campaign_helper(user, campaign, action)
    "#{campaign.contributing_individual_actions(user).count} out of #{campaign.required_individual_occurrences}"
  end

  def formatted_date(date)
  	date.strftime('%B, %Y')
  end
end
