class Level
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :description, type: String
  field :message, type: String
  field :points, type: Integer
  
  validates_presence_of :name
end
