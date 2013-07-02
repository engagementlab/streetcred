class ActionType
  include Mongoid::Document
  
  belongs_to :channel
  has_and_belongs_to_many :campaigns, index: true
  
  field :name
  field :provider_uid, type: String
  
  index({ name: 1 })
  index({ provider_uid: 1 })
  
  validates_presence_of :channel
  before_save :strip_name, :strip_provider_uid
  
  private
  
  def strip_name
    name.strip if name.present?
  end
  
  def strip_provider_uid
    provider_uid.strip if provider_uid.present?
  end
  
end
