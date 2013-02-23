class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :awards, dependent: :delete
  
  field :name, type: String
  
  validates_presence_of :name
  
end
