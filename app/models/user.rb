class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :actions, dependent: :delete
  has_and_belongs_to_many :awards
  embeds_many :points
  
  
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :phone, type: String
  
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










