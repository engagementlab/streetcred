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
  
  private
  
  def associate_channel
    self.update_attribute(:channel_id, Channel.where(key: key).first.try(:id))
  end
  
  def assign_awards
    user = self.user
    # find in-range awards with a required_action with the same name as the incoming action
    matching_awards = Award.elem_match(required_actions: {name: self.action_type}).lt(start_time: Time.now).gt(end_time: Time.now)
    
    matching_awards.each do |award|      
      # find all actions that match at least one of the action_types definied in the award   
      matching_actions  = user.actions.gt(created_at: award.start_time).lt(created_at: award.end_time).in(action_type: award.required_actions.collect {|x| x.name}).in(key: award.channels.collect {|x| x.key})
      # assign the award
      if award.required_occurrences == matching_actions.count
        self.awards << award
        user.awards << award
      end
    end
    self.save
    user.save
  end
end
