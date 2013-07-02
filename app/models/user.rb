class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :actions, dependent: :delete
  has_and_belongs_to_many :campaigns, index: true
  
  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:foursquare]

  field :contact_id, type: String, default: ""
  field :first_name, type: String, default: ""
  field :last_name, type: String, default: ""
  field :email, type: String, default: ""
  field :phone, type: String, default: ""
  field :shared, type: Boolean, default: true

  # Omniauth
  field :provider, type: String
  field :provider_uid, type: String
  field :info, type: String
  field :credentials, type: String
  field :extra, type: String
  
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
  

  def full_name
    if self.first_name.blank? && self.last_name.blank?
      self.id
    else
      "#{self.first_name} #{self.last_name}"
    end
  end

  def matching_actions(campaign)    
    if campaign.start_time.present? && campaign.end_time.present? && campaign.required_individual_occurrences > 0
      # find all actions that match at least one of the action_types defined on the campaign
      self.actions.gt(created_at: campaign.start_time).lt(created_at: campaign.end_time).in(action_type: campaign.required_actions.collect {|x| x.name})
    elsif campaign.required_individual_occurrences > 0
      self.actions.in(action_type_id: campaign.action_types.collect {|x| x.id})
    end
  end

  def progress_toward_campaign(campaign)
    self.matching_actions(campaign).count / campaign.required_individual_occurrences.to_f
  end
  
  def campaigns_completed_by_action(action)
    # all user.campaigns have been completed; those associated with the action were completed by the action
    # however, this is probably not ideal since it's only the campaign.actions.last that actually completed the campaign
    if action.user == self
      self.campaigns.collect {|campaign| campaign if campaign.actions.where(user_id: self.id).asc(:created_at).last == action}.compact
    end
  end
  
  def campaigns_in_progress_by_action(action)
    if action.user == self
      action.campaigns.nin(user_ids: self.id)
    end
  end
end










