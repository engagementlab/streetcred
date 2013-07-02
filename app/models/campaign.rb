class Campaign
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps

  has_and_belongs_to_many :actions, index: true
  has_and_belongs_to_many :channels, index: true
  has_and_belongs_to_many :users, index: true
  embeds_many :required_actions
  accepts_nested_attributes_for :required_actions, allow_destroy: true
    
  validates_presence_of :name, :required_actions
  validate :required_actions_unique
  
  field :name, type: String
  field :description, type: String
  field :badge_url, type: String
  field :required_individual_occurrences, type: Integer, :default => 1
  field :required_community_occurrences, type: Integer, :default => 1
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :latitude, type: BigDecimal
  field :longitude, type: BigDecimal
  field :radius, type: BigDecimal
  field :coordinates, type: Array
  
  index({ name: 1 }, { unique: true})
  index({ start_time: 1 })
  index({ end_time: 1 })
  index({ coordinates: "2d" })
  index "required_actions.name" => 1

  before_save :set_coordinates

    # if lat lng exist, validate that radius exists 

  def channel_keys
    channels.collect {|x| x.api_key}
  end
  
  def required_action_types
    required_actions.collect {|x| x.name}
  end

  # def individual_requirements_met(user)
    
  # end

  # def community_requirements_mat
    
  # end
  
  def requirements_met?(user)
    # find the actions dynamically, not based on which ones have been associated with the campaign
    # in other words, including actions from before the campaign was created, but which meet its criteria
    matching_user_actions = user.actions.in(api_key: self.channel_keys).in(action_type: self.required_action_types).gt(created_at: self.start_time).lt(created_at: self.end_time)
    
    if matching_user_actions.blank?
      return false
    else
      # if the radius is set but hasn't been exceeded, return false regardless of occurrences
      if self.radius.present? && self.radius_exceeded?(matching_user_actions) == false
        return false
      elsif self.radius.present? && self.radius_exceeded?(matching_user_actions)
        # need to make sure the action that meets the occurrences is also the one that exceeds the radius
      else
        requirements_met = self.required_actions.collect {|x| (matching_user_actions.where(action_type: x.name).count >= x.occurrences)}
        requirements_met.include?(true)
      end
    end
  end
  
  def actions_within_radius(actions, center_point)
    actions.within_circle(coordinates: [center_point, self.radius])
  end
  
  def radius_exceeded?(actions)
    # make sure the actions have coordinates
    actions_with_coordinates = actions.exists(coordinates: true).ne(coordinates: nil)
    if self.latitude.present? && self.longitude.present?
      center_point = [self.longitude.to_f, self.latitude.to_f]
    else
      center_point = Geocoder::Calculations.geographic_center(actions_with_coordinates.collect {|x| x.coordinates})
    end
    max_distance = (actions_with_coordinates.geo_near(center_point).spherical.max_distance * 3959)
    # make sure the distance exceeds the radius and that at least one action is within the circle
    max_distance > self.radius && actions_within_circle(actions_with_coordinates, center_point).present?
  end

  private
  
  def set_coordinates
    if self.latitude.present? && self.longitude.present?
      self.coordinates = [self.longitude.try(:to_f), self.latitude.try(:to_f)]
    else
      self.coordinates = nil
    end
  end
  
  def required_actions_unique
    errors[:base] << "Required actions can't contain duplicates" if required_actions.collect {|x| x.name}.uniq.length != required_actions.length
  end
  
end
