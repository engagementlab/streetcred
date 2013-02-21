class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :actions
  has_and_belongs_to_many :awards
  
  
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
end
