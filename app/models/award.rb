class Award
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :campaign
  has_and_belongs_to_many :actions
  has_and_belongs_to_many :channels
  has_and_belongs_to_many :users
  embeds_many :required_actions
  accepts_nested_attributes_for :required_actions, allow_destroy: true
    
  validates_presence_of :name, :points, :channels, :required_actions, :start_time, :end_time
  validate :required_actions_unique
  
  field :name, type: String
  field :occurences, type: Integer, default: 1
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :message, type: String
  field :badge_url, type: String
  field :points, type: Integer, default: 0

  def required_occurences
    occurences = 0
    self.required_actions.each do |x|
      occurences += x.occurences if x.occurences.present?
    end
    return occurences
  end
  private
  def required_actions_unique
    errors[:base] << "Required actions can't contain duplicates" if required_actions.collect {|x| x.name}.uniq.length != required_actions.length
  end
  
  
end
