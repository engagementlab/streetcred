class ActionType
  include Mongoid::Document
  
  embedded_in :awards
end
