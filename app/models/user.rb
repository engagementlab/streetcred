class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :actions, dependent: :delete
  has_and_belongs_to_many :awards, dependent: :delete
  
  
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String

  def progress(award)
    if matching_actions(award).count == 0
      number_to_percentage(0, :precision => 0)
    else
      number_to_percentage((matching_actions(award).count / award.occurences.to_i), :precision => 0)
    end
  end

  def matching_actions(award)
    if award.start_time.present? && award.end_time.present? && award.occurences.present?
      # find all actions that match at least one of the action_types definied in the award
      self.actions.gt(created_at: award.start_time).lt(created_at: award.end_time).in(action_type: award.action_types.collect {|x| x.name}).in(key: award.channels.collect {|x| x.key})
    elsif award.occurences.present?
      self.actions.in(action_type: award.action_types.collect {|x| x.name}).in(key: award.channels.collect {|x| x.key})
    end
  end
end
