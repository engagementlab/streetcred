class Award
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :campaign
  has_and_belongs_to_many :actions
  has_and_belongs_to_many :channels
  has_and_belongs_to_many :users
  has_and_belongs_to_many :action_types
  
  accepts_nested_attributes_for :channels
  
  validates_presence_of :name
  validates_presence_of :channels
  validates_presence_of :action_types
  validates_presence_of :occurences
    
  field :name
  field :occurences
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :message
  field :badge_url
  
end
