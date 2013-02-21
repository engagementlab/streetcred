module Admin::CampaignsHelper
  
  def awards_count_helper(campaign)
    if campaign.awards.blank? || campaign.awards.count == 0
      link_to 'Add Awards', new_admin_campaign_award_path(campaign)
    elsif campaign.awards.count == 1
      link_to "#{campaign.awards.count} Award", admin_campaign_awards_path(campaign)
    else
      link_to "#{campaign.awards.count} Awards", admin_campaign_awards_path(campaign)
    end
  end
end
