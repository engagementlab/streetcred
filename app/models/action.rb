class Action
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user
  has_and_belongs_to_many :awards
  accepts_nested_attributes_for :awards
  
  
  field :source
  field :case_id
  field :action_type
  field :description
  field :location
  field :lat, type: BigDecimal
  field :lng, type: BigDecimal
  field :image, type: Boolean
  
  after_create :assign_awards
  
  private
  
  def assign_awards
    user = self.user
    # find awards marked with the same action_type as the current action
    matching_awards = Award.elem_match(action_types: {name: self.action_type})
    
    matching_awards.each do |award|
      # find all actions that match at least one of the action_types definied in the award   
      matching_actions = user.actions.in(action_type: award.action_types.collect {|x| x.name})
      logger.info "*************** #{award.name} = #{matching_actions.count}/#{award.required_volume}"
      if award.required_volume.to_i == matching_actions.count
        logger.info "**************** pushing #{award.name} award into #{user.email} awards"
        self.awards << award
        user.awards << award
      end
    end
    user.save
  end
end
