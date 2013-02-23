class Action
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user
  belongs_to :channel
  has_and_belongs_to_many :awards
  
  
  field :key
  field :case_id
  field :action_type
  field :description
  field :location
  field :lat, type: BigDecimal
  field :lng, type: BigDecimal
  field :image, type: Boolean
  
  after_create :associate_channel, :assign_awards
    
  def associate_channel
    channel = Channel.where(key: self.key).first
    channel.actions << self if channel.present? 
  end
  
  def assign_awards
    user = self.user
    # find awards that are in-range and that match the action_type and channel of the incoming action
    matching_awards = Award.elem_match(required_actions: {name: self.action_type}).lt(start_time: Time.now).gt(end_time: Time.now)
    
    # iterate through the awards and determine whether their requirements have been met
    matching_awards.each do |award|
      award_requirements_met = []
      actions_that_match_the_award = user.actions.where(key: self.key).gt(created_at: award.start_time).lt(created_at: award.end_time)
      # iterate through the requirements and determine whether each has been met
      award.required_actions.each do |requirement|
        actions_that_match_the_requirement = actions_that_match_the_award.where(action_type: requirement.name)
        requirement_met = (actions_that_match_the_requirement.count >= requirement.occurrences)
        award_requirements_met << requirement_met
      end
      
      # assign the award to the user and action (for tracking purposes) if the award's requirements have all been met
      if award_requirements_met.all? == true
        self.awards << award
        user.awards << award
      end
    end
  end
end
