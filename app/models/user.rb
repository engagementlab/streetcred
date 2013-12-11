class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Gravtastic
  gravtastic
  
  has_many :actions, dependent: :delete
  has_many :providers, dependent: :delete
  has_and_belongs_to_many :campaigns, index: true
  
  scope :active, where(:sign_in_count.exists => true).where(:sign_in_count.gt => 0 )
  scope :visible, where(:shared => true)

  devise :database_authenticatable, :registerable, :recoverable, :trackable, :omniauthable, :omniauth_providers => [:foursquare, :instagram]

  field :contact_id, type: String, default: ""
  field :first_name, type: String, default: ""
  field :last_name, type: String, default: ""
  field :neighborhood, type: String
  field :email, type: String, default: ""
  field :phone, type: String, default: ""
  field :slug, type: String
  field :shared, type: Boolean, default: true
  field :map_visible, type: Boolean, default: true
  field :score, type: Integer, default: 0
  field :completed_campaigns_count, type: Integer, default: 0
  field :completed_community_campaigns_count, type: Integer, default: 0

  # # Omniauth
  # field :provider, type: String
  # field :provider_uid, type: String
  # field :info, type: String
  # field :credentials, type: String
  # field :extra, type: String
  
  ## Database authenticatable
  field :encrypted_password, :type => String, default: ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  
  # index({ provider_uid: 1 }, { unique: true})
  index({ slug: 1 }, { unique: true})

  if Rails.env == 'production'
    has_mongoid_attached_file :gravatar, storage: :s3, url: ':s3_domain_url', path: '/:class/:attachment/:id_partition/:style/:filename', s3_protocol: 'https', s3_credentials: { bucket: ENV['AWS_BUCKET'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }, styles: { icon: '30x30#', thumbnail: '70x70#', large: '150x150>' }
  else
    has_mongoid_attached_file :gravatar, :url => "users/:style/:filename", :path => "#{Rails.root}/public/assets/users/:style/:filename", styles: { icon: '30x30#', thumbnail: '70x70#', large: '150x150>' }
  end

  def claimed?
    sign_in_count.present? && sign_in_count > 0
  end

  def self.update_scores!
    self.all.each do |user|
      user.update_score!
    end
  end

  def update_score!
    total = 0
    total += (actions.count * 5)
    total += (completed_campaigns.count * 25)
    total += (completed_community_campaigns.count * 50)
    self.update_attributes(score: total)
  end

  def update_completed_campaigns_count!
    self.update_attributes(completed_campaigns_count: self.completed_campaigns.count)
  end

  def self.completed_campaigns_count
    total = 0
    self.active.visible.each do |user|
      total += user.completed_campaigns_count
    end
    total
  end

  def self.update_completed_community_campaigns_count!
    self.all.each do |user|
      user.update_attributes(completed_community_campaigns_count: self.completed_community_campaigns.count)
    end
  end

  def self.completed_community_campaigns_count
    total = 0
    self.active.visible.each do |user|
      total += user.completed_campaigns_count
    end
    total
  end

  def self.total_actions_count
    total = 0
    self.active.visible.each do |user|
      total += user.actions.count
    end
    total
  end

  def display_name
    if first_name.blank? && last_name.blank?
      'anonymous'
    else
      "#{self.first_name} #{self.last_name}"
    end
  end

  def name_or_email
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    else
      email
    end
  end

  def self.completed_campaigns
    self.all.collect {|x| x.completed_campaigns}
  end

  def channels
    actions.collect {|x| x.action_type.try(:channel)}.uniq
  end

  def completed_campaigns
    Campaign.all.select {|x| x.requirements_met_by_individual?(self)}
  end

  def completed_community_campaigns
    Campaign.all.select {|x| x.requirements_met_by_individual?(self) && x.requirements_met_by_community?}
  end

  def expired_completed_campaigns
    Campaign.all.select {|x| x.requirements_met_by_individual?(self) && x.expired?}
  end

  def expired_contributed_to_campaigns
    Campaign.all.select {|x| x.contributing_individual_actions(self).present? && x.expired?}    
  end
  
  def campaigns_completed_by_action(action)
    # all user.campaigns have been completed; those associated with the action were completed by the action
    # however, this is probably not ideal since it's only the campaign.actions.last that actually completed the campaign
    if action.user == self
      campaigns.select {|campaign| campaign if ((campaign.actions.where(user_id: self.id).count == campaign.required_individual_occurrences) && (campaign.actions.where(user_id: self.id).asc(:created_at).last == action))}
    end
  end
  
  def campaigns_in_progress_by_action(action)
    if action.user == self
      action.campaigns.nin(user_ids: self.id)
    end
  end

  def reach
    if actions.mappable.present?
      center_point = Geocoder::Calculations.geographic_center(actions.mappable.collect {|x| x.coordinates})
      actions.mappable.geo_near(center_point).spherical.distance_multiplier(3959).average_distance
    else
      nil
    end
  end
end










