class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :campaigns, index: true
  
  field :subject, type: String
  field :body, type: String
  field :first_action, type: Boolean, default: false
  field :last_action, type: Boolean, default: false
  field :action, type: String
  field :action_number, type: Integer
  field :api_key, type: String
  

end
