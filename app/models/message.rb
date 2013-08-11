class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :campaigns, index: true
  
  field :name, type: String
  field :api_key, type: String
  

end
