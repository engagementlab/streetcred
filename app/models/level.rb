class Level
  include Mongoid::Document
  
  field :name, type: String
  field :description, type: String
  field :points, type: Integer
  
  validates_presence_of :name
end
