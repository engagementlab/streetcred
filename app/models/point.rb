class Point
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :user
  
  field :amount, type: Integer, default: 0
end
