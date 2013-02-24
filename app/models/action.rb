class Action
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user
  belongs_to :channel
  has_and_belongs_to_many :awards, dependent: :nullify
  
  
  field :key
  field :case_id
  field :action_type
  field :description
  field :location
  field :lat, type: BigDecimal
  field :lng, type: BigDecimal
  field :image, type: Boolean
  
  before_save :set_channel_id
  after_create :assign_awards
    
  def set_channel_id
    self.channel_id = Channel.where(key: key).first.try(:id)
  end
  
  def assign_awards
    user = self.user
    # find awards that are in-range and match the action_type and channel of the incoming action
    matching_awards = Award.elem_match(required_actions: {name: self.action_type}).in(channel_ids: [self.channel_id]).lt(start_time: Time.now).gt(end_time: Time.now)
    logger.info "************ found #{matching_awards.count} matching awards"
    
    # iterate through the awards and determine whether their requirements have been met
    matching_awards.each do |award|
      award_requirements_met = []
      award_actions = user.actions.in(key: award.channel_keys).gt(created_at: award.start_time).lt(created_at: award.end_time)
      logger.info "************ found #{award_actions.count} actions that match the award criteria"
      
      # iterate through the requirements and determine if their conditions have been met
      award.required_actions.each do |requirement|
        requirement_actions = award_actions.where(action_type: requirement.name)
        requirement_met = (requirement_actions.count >= requirement.occurrences)
        award_requirements_met << requirement_met
      end

      logger.info "************ award requirements look like #{award_requirements_met}"
      
      # assign the award to the user and action (for tracking purposes) if the award's requirements have been met
      if award.operator == 'AND' && award_requirements_met.all?
        unless user.awards.include?(award)
          self.awards << award
          user.awards << award
        end
      elsif award.operator == 'OR' && award_requirements_met.include?(true)
        unless user.awards.include?(award)
          self.awards << award
          user.awards << award
        end
      end
    end
  end
end
