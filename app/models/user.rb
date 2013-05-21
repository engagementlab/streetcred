class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :actions, dependent: :delete
  has_and_belongs_to_many :awards, index: true
  embeds_many :points
  
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
  
  def total_points
    (self.points.collect {|x| x.amount}).try(:sum)
  end

  def progress_toward_campaign(campaign)
    progress = 0
    awards = campaign.awards
    awards.each do |award|
      progress += progress_toward_award(award)
    end
    progress / awards.count
  end

  def progress_toward_award(award)
    if self.matching_actions(award).count == 0
      0
    else
      self.matching_actions(award).count / award.required_occurrences.to_f
    end
  end

  # TODO do we need to account for ALL / ANY logic here?
  def matching_actions(award)    
    if award.start_time.present? && award.end_time.present? && award.required_occurrences > 0
      # find all actions that match at least one of the action_types definied in the award
      self.actions.gt(created_at: award.start_time).lt(created_at: award.end_time).in(action_type: award.required_actions.collect {|x| x.name}).in(api_key: award.channels.collect {|x| x.api_key})
    elsif award.required_occurrences > 0
      self.actions.in(action_type: award.action_types.collect {|x| x.name}).in(api_key: award.channels.collect {|x| x.api_key})
    end
  end
  
  def awards_earned_by_action(action)
    # all user.awards have been earned; those associated with the action were earned by the action
    # however, this is probably not ideal since it's only the award.actions.last that actually earned the award
    if action.user == self
      self.awards.collect {|award| award if award.actions.where(user_id: self.id).asc(:created_at).last == action}.compact
    else
      nil
    end
  end
  
  def awards_in_progress_by_action(action)
    if action.user == self
      action.awards.nin(user_ids: self.id)
    else
      nil
    end
  end
end










