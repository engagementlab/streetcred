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

  def badge_helper(campaign, user=nil)
  	if user.present?
			if campaign.progress_by_community >= 1.0
				image_tag campaign.community_badge.url(:badge)
			elsif campaign.progress_by_individual(user) >= 1.0
				image_tag campaign.individual_badge.url(:badge)
			else
				image_tag campaign.badge_icon.url(:badge)
			end
		else
			image_tag campaign.badge_icon.url(:badge)
		end
  end
end
