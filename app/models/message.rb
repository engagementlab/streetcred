class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :campaigns, index: true
  
  field :subject, type: String
  field :body, type: String
  field :first_action, type: Boolean, default: false
  field :last_action, type: Boolean, default: false
  field :action, type: String
  field :campaign_type, type: String
  field :campaign_percentage, type: BigDecimal
  field :campaign_countdown, type: Integer
  field :api_key, type: String
  
  validates_presence_of :subject, :body, :campaign_type
  validate :campaign_completion_or_campaign_countdown

  def campaign_completion_or_campaign_countdown
  	if self.campaign_percentage.blank? && campaign_countdown.blank?
  		errors[:base] << "Campaign completion and campaign countdown can't both be blank"
  	elsif self.campaign_percentage.present? && self.campaign_countdown.present?
  		errors[:base] << "Campaign completion and campaign countdown cannot both be selected"
		end  		
  end
end
