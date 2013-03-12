module Admin::CampaignsHelper
  
  def awards_count_helper(campaign)
    if campaign.awards.blank? || campaign.awards.count == 0
      '0 Awards'
    elsif campaign.awards.count == 1
      "#{campaign.awards.count} Award"
    else
      "#{campaign.awards.count} Awards"
    end
  end
end
