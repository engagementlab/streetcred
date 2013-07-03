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

  def matching_actions
    Action.in(action_type_id: required_actions.collect(&:action_type_id)).gt(created_at: start_time).lt(created_at: end_time)
  end

  def community_requirements_met?
    if matching_actions.count >= required_community_occurrences
      if radius.blank?
        return true
      elsif radius.present?
        radius_exceeded?(matching_actions)
      end
    else # if matching_actions < required_individual_occurrences
      return false
    end
  end

  def matching_user_actions(user)
    Action.in(action_type_id: required_actions.collect(&:action_type_id)).gt(created_at: start_time).lt(created_at: end_time).where(user_id: user.id)
  end

  def individual_requirements_met?(user)
    if matching_user_actions(user).count >= required_individual_occurrences
      if radius.blank?
        return true
      elsif radius.present?
        radius_exceeded?(matching_actions)
      end
    else # if matching_actions < required_individual_occurrences
      return false
    end
  end
  
  def actions_within_radius(actions, center_point)
    actions.within_circle(coordinates: [center_point, self.radius])
  end
  
  def radius_exceeded?(actions)
    if radius.present?
      # make sure the actions have coordinates
      actions_with_coordinates = actions.exists(coordinates: true).ne(coordinates: nil)
      if latitude.present? && longitude.present?
        center_point = [longitude.to_f, latitude.to_f]
      else
        center_point = Geocoder::Calculations.geographic_center(actions_with_coordinates.collect {|x| x.coordinates})
      end
      max_distance = (actions_with_coordinates.geo_near(center_point).spherical.max_distance * 3959)
      # make sure the distance exceeds the radius and that at least one action is within the circle
      max_distance > radius && actions_within_circle(actions_with_coordinates, center_point).present?
    else
      return false
    end
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
    errors[:base] << "Required actions can't contain duplicates" if required_actions.collect {|x| x.action_type.try(:name)}.uniq.length != required_actions.length
  end
  
end
