class Channel
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :actions, :foreign_key => 'api_key', :primary_key => 'api_key'
  has_and_belongs_to_many :awards, index: true
  
  field :name, type: String
  field :api_key, type: String
  
  index({ name: 1 }, { unique: true})
  index({ api_key: 1 }, { unique: true})
  
  validates_presence_of :name
  
  before_create :generate_api_key
  
  def rekey!
    self.update_attribute(:api_key, SecureRandom.hex(20)) 
  end
  
  private
  def generate_api_key
    self.api_key = SecureRandom.hex(20) 
  end
end
