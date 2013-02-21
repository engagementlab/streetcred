class ActionType
  include Mongoid::Document
  
  has_and_belongs_to_many :awards
  
  field :name
  field :points, type: Integer, default: 0
  
end
