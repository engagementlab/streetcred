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
      start_time  = award.start_time
      end_time    = award.end_time
      occurences  = award.occurences.to_i
      
      if start_time.present? && end_time.present? && occurences.present?
        matching_actions  = user.actions.gt(created_at: award.start_time).lt(created_at: award.end_time).in(action_type: award.action_types.collect {|x| x.name})
        if start_time < Time.now && end_time > Time.now && occurences == matching_actions.count
          self.awards << award
          user.awards << award
        end
      elsif occurences.present?
        matching_actions  = user.actions.in(action_type: award.action_types.collect {|x| x.name})
        if occurences == matching_actions.count
          self.awards << award
          user.awards << award
        end
      end
    end
    self.save
    user.save
  end
end
