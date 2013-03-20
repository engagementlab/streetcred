class Award
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :campaigns
  has_and_belongs_to_many :actions
  has_and_belongs_to_many :channels
  has_and_belongs_to_many :users
  embeds_many :required_actions
  accepts_nested_attributes_for :required_actions, allow_destroy: true
    
  validates_presence_of :name, :points, :channels, :required_actions, :start_time, :end_time
  validate :required_actions_unique
  
  field :name, type: String
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :description, type: String
  field :message, type: String
  field :badge_url, type: String
  field :points, type: Integer, default: 0
  field :operator, type: String
  
      
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
  
  private
  
  def required_actions_unique
    errors[:base] << "Required actions can't contain duplicates" if required_actions.collect {|x| x.name}.uniq.length != required_actions.length
  end
  
  
end
