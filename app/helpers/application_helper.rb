module ApplicationHelper
  def progress_toward_campaign_helper(user, campaign, action)
    "#{campaign.contributing_individual_actions(user).count} out of #{campaign.required_individual_occurrences}"
  end

  def formatted_month_year(date)
  	date.strftime('%B, %Y')
  end

  def formatted_date(date)
  	date.strftime('%m/%d/%Y')  	
  end

  def pluralizer_helper(term, count)
  	if count == 1
  		term.singularize
  	else
  		term.pluralize
  	end
  end
end
