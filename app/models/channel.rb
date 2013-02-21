class Channel
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :actions
  has_and_belongs_to_many :awards
  
  field :name, type: String
  field :key, type: String
  
  validates_presence_of :name
  
  before_create :generate_key
  
  def rekey!
    self.update_attribute(:key, SecureRandom.hex(20)) 
  end
  
  private
  def generate_key
    self.key = SecureRandom.hex(20) 
  end
end
