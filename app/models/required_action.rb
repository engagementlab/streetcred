class RequiredAction
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :campaign
  belongs_to :action_type
    
end
