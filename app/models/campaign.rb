class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :awards
  
  field :name, type: String
  
  validates_presence_of :name
  
end
