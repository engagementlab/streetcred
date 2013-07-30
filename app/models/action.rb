class Action  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  
  belongs_to :user, index: true
  belongs_to :channel, :foreign_key => 'api_key', :primary_key => 'api_key'
  belongs_to :action_type
  has_and_belongs_to_many :campaigns, dependent: :nullify, index: true
  
  
  field :api_key, type: String
  field :record_id, type: String # provider UID
  field :case_id, type: String
  field :action_type, type: String
  field :description, type: String
  field :shared, type: Boolean
  field :location, type: String
  field :latitude, type: BigDecimal
  field :longitude, type: BigDecimal
  field :coordinates, type: Array
  field :address, type: String
  field :city, type: String
  field :zipcode, type: String
  field :state, type: String
  field :url, type: String
  field :photo_url, type: String
  field :timestamp, type: String
  # StreetBump
  field :started_at, type: String
  field :duration, type: BigDecimal
  field :bumps, type: Integer, :default => 0
  
  index({ api_key: 1 })
  index({ coordinates: "2d" })

  before_create :set_coordinates
  after_create :assign_campaigns
  
  def reversed_coordinates
    coordinates.try(:reverse)
  end

  def matching_campaigns
    Campaign.elem_match(required_actions: {action_type_id: action_type.id}).lt(start_time: created_at).gt(end_time: created_at)
  end

  private
  
  def set_coordinates
    if self.latitude.present? && self.longitude.present?
      self.coordinates = [self.longitude.try(:to_f), self.latitude.try(:to_f)]
    end
  end
  
  # this callback assigns the incoming action to relevant campaigns, and assigns campaigns to the user if the campaign's 
  # requirements have been met
  def assign_campaigns
    # iterate through the matching campaigns and determine whether their requirements have been met
    matching_campaigns.each do |campaign|
      campaign.actions << self
      unless user.campaigns.include?(campaign)
        user.campaigns << campaign
      end
    end
  end
end
