class Action
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user
  belongs_to :channel, :foreign_key => 'api_key', :primary_key => 'api_key'
  has_and_belongs_to_many :awards, dependent: :nullify
  
  
  field :key
  field :case_id
  field :action_type
  field :description
  field :location
  field :latitude, type: BigDecimal
  field :longitude, type: BigDecimal
  field :image, type: Boolean
  
  after_create :assign_awards
  
  def assign_awards
    user = self.user
    # find awards that are in-range and match the action_type and channel of the incoming action
    matching_awards = Award.elem_match(required_actions: {name: self.action_type}).in(channel_ids: [self.channel_id]).lt(start_time: self.created_at).gt(end_time: self.created_at)
    
    # iterate through the awards and determine whether their requirements have been met
    matching_awards.each do |award|
      # assign the incoming action to the matching award for tracking purposes
      award.actions << self
      award_actions = user.actions.in(key: award.channel_keys).gt(created_at: award.start_time).lt(created_at: award.end_time)
      
      # iterate through the requirements and determine if they have been met
      award_requirements_met = []
      award.required_actions.each do |requirement|
        requirement_actions = award_actions.where(action_type: requirement.name)
        requirement_met = (requirement_actions.count >= requirement.occurrences)
        award_requirements_met << requirement_met
      end
      
      # assign the award to the user if the award's requirements have been met
      if award.operator == 'ALL' && award_requirements_met.all?
        unless user.awards.include?(award)
          user.awards << award
        end
      elsif award.operator == 'ANY' && award_requirements_met.include?(true)
        unless user.awards.include?(award)
          user.awards << award
        end
      end
    end
  end
end
