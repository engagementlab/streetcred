class RequiredAction
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :award
  belongs_to :action_type
  
  field :name, type: String
  field :occurences, type: Integer
  
end
