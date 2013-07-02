class RequiredAction
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :campaign
  
  field :name, type: String
  
end
