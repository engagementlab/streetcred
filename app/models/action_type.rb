class ActionType
  include Mongoid::Document
  
  has_and_belongs_to_many :awards, index: true
  
  field :name
  field :provider_uid, type: String
  field :points, type: Integer, default: 0
  
  index({ name: 1 })
  index({ provider_uid: 1 })
  
  
  before_save :strip_name, :strip_provider_uid
  
  private
  
  def strip_name
    name.strip
  end
  
  def strip_provider_uid
    provider_uid.strip
  end
  
end
