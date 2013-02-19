class Award
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_and_belongs_to_many :actions
  has_and_belongs_to_many :users
  embeds_many :action_types
  accepts_nested_attributes_for :action_types
  # validate :action_types, :presence
    
  field :name
  field :required_volume
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :message
  field :badge_url
  
end
