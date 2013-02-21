class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :awards
  
  field :name
end
