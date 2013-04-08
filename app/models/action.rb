class Action
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user, index: true
  belongs_to :channel, :foreign_key => 'api_key', :primary_key => 'api_key'
  has_and_belongs_to_many :awards, dependent: :nullify, index: true
  
  
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
  
  index({ api_key_uid: 1 }, { unique: true, name: "api_key_index" })
  index({ coordinates: "2d" })

  after_create :assign_awards
  before_save :set_coordinates
  
  def set_coordinates
    if self.latitude.present? && self.longitude.present?
      self.coordinates = [self.longitude, self.latitude]
    end
  end
  
  # this callback assigns incoming actions to relevant awards, and assigns awards to users if the award's 
  # requirements have been met
  def assign_awards
    user = self.user
    # find awards that are in-range and match the action_type and channel of the incoming action
    matching_awards = Award.elem_match(required_actions: {name: self.action_type}).in(channel_ids: [self.channel.try(:id)]).lt(start_time: self.created_at).gt(end_time: self.created_at)
    
    # iterate through the matching awards and determine whether their requirements have been met
    matching_awards.each do |award|
      unless user.awards.include?(award)
        # assign the action to the award in order to track progress
        award.actions << self
        
        if award.requirements_met?(user)
          user.awards << award
        end
      end
    end
  end
end
