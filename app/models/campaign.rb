class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :awards
  
  field :name, type: String
  field :description, type: String
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  
  validates_presence_of :name
  
end
