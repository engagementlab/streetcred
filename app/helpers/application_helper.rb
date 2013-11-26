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
      # only show the community badge if the user has earned the individual badge
			if campaign.progress_by_individual(user) >= 1 && campaign.progress_by_community >= 1
				"#{link_to image_tag(campaign.community_badge.url(:badge)), '#', class: 'openbadge-link', :data => { :api => '#{badge_api_path(user, campaign)}' }}" +
        "<div style='margin-top: 15px;'>" +
        "#{image_tag('send_to_open_badges.png', class: 'openbadge-link')}" +
        "</div>"
			elsif campaign.progress_by_individual(user) >= 1
				"#{link_to image_tag(campaign.individual_badge.url(:badge)), '#', class: 'openbadge-link', :data => { :api => '#{badge_api_path(user, campaign)}' }}" +
        "<div style='margin-top: 15px;'>" +
        "#{image_tag('send_to_open_badges.png', class: 'openbadge-link')}" +
        "</div>"			
      else
				image_tag '/assets/badge-blank.png'
			end
		else
			image_tag campaign.badge_icon.url(:badge)
		end
  end
end
