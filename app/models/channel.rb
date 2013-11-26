class Channel
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Slug
  
  has_many :action_types, dependent: :delete
  has_many :actions, :foreign_key => 'api_key', :primary_key => 'api_key'
  
  slug :name
  
  field :name, type: String
  field :api_key, type: String
  
  index({ name: 1 }, { unique: true})
  index({ api_key: 1 }, { unique: true})
  
  validates_presence_of :name
  
  before_create :generate_api_key
  
  if Rails.env == 'production'
    has_mongoid_attached_file :logo, storage: :s3, url: ':s3_domain_url', path: '/:class/:attachment/:id_partition/:style/:filename', s3_protocol: 'https', s3_credentials: { bucket: ENV['AWS_BUCKET'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }, styles: { thumb: '48x48#' }
  else
    has_mongoid_attached_file :logo, :url => "channels/:style/:filename", :path => "#{Rails.root}/public/assets/channels/:style/:filename", styles: { thumb: '48x48#'}
  end

  def rekey!
    self.update_attribute(:api_key, SecureRandom.hex(20)) 
  end
  
  private
  def generate_api_key
    self.api_key = SecureRandom.hex(20) 
  end
end
