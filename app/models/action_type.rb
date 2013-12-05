class ActionType
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  
  belongs_to :channel
  has_many :actions

  slug :name
  
  field :name, type: String
  field :description, type: String
  field :provider_uid, type: String
  
  index({ name: 1 })
  index({ provider_uid: 1 })
  
  validates_presence_of :channel
  before_save :strip_name, :strip_provider_uid, :downcase_provider_id
  
  private
  
  def strip_name
    name.strip if name.present?
  end

  def downcase_provider_id
    provider_id.downcase if provider_id.present?
  end
  
  def strip_provider_uid
    provider_uid.strip if provider_uid.present?
  end
  
end
