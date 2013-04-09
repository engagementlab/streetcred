class Award
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :campaigns, index: true
  has_and_belongs_to_many :actions, index: true
  has_and_belongs_to_many :channels, index: true
  has_and_belongs_to_many :users, index: true
  embeds_many :required_actions
  accepts_nested_attributes_for :required_actions, allow_destroy: true
    
  validates_presence_of :name, :points, :channels, :required_actions, :start_time, :end_time
  validate :required_actions_unique
  
  field :name, type: String
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :description, type: String
  field :start_message, type: String
  field :mid_message, type: String
  field :success_message, type: String  
  field :badge_url, type: String
  field :points, type: Integer, default: 0
  field :operator, type: String
  field :radius, type: BigDecimal
  
  index({ name: 1 }, { unique: true})
  index({ start_time: 1 })
  index({ end_time: 1 })
  index "required_actions.name" => 1
      
  def required_occurrences
    occurrences = 0
    if self.operator == 'ALL'
      self.required_actions.each do |action|
        occurrences += action.occurrences if action.occurrences.present?
      end
    elsif self.operator == 'ANY'
      occurrences = self.required_actions.asc(:occurrences).first.occurrences
    end
    return occurrences
  end
  
  def required_occurrences_by_action(action)
    occurrences = 0
    if self.operator == 'ALL'
      self.required_actions.each do |action|
        occurrences += action.occurrences if action.occurrences.present?
      end
    elsif self.operator == 'ANY'
      occurrences = self.required_actions.where(name: action.action_type).first.occurrences
    end
    return occurrences
  end
  
  def channel_keys
    channels.collect {|x| x.api_key}
  end
  
  def required_action_types
    required_actions.collect {|x| x.name}
  end
  
  def requirements_met?(user)
    # find the actions dynamically, not based on which ones have been associated with the award
    # in other words, including actions from before the award was created, but which meet its criteria
    matching_user_actions = user.actions.in(api_key: self.channel_keys).in(action_type: self.required_action_types).gt(created_at: self.start_time).lt(created_at: self.end_time)
    
    if matching_user_actions.blank?
      return false
    else
      # if the radius is set but hasn't been exceeded, return false regardless of occurrences
      if self.radius.present? && self.radius_not_exceeded?(matching_user_actions)
        requirements_met = [false]
      # otherwise, check the number of occurrences
      else      
        requirements_met = self.requirements_met(matching_user_actions)
      end

      if self.operator == 'ALL'
        requirements_met.all?
      elsif self.operator == 'ANY'
        requirements_met.include?(true)
      end
    end
  end
  
  def radius_not_exceeded?(actions)
    # make sure the actions have coordinates
    actions_with_coordinates = actions.ne(coordinates: nil)
    geographic_center = Geocoder::Calculations.geographic_center(actions_with_coordinates.collect {|x| x.reversed_coordinates})
    max_distance = (actions_with_coordinates.geo_near(geographic_center).spherical.max_distance * 3959)
    logger.info max_distance
    max_distance <= self.radius
  end
  
  def requirements_met(actions)
    self.required_actions.collect {|x| (actions.where(action_type: x.name).count >= x.occurrences)}
  end
  
  private
  
  def required_actions_unique
    errors[:base] << "Required actions can't contain duplicates" if required_actions.collect {|x| x.name}.uniq.length != required_actions.length
  end
  
  
end
