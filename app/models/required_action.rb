class RequiredAction
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :award
  belongs_to :action_type
  
  field :name, type: String
  field :occurrences, type: Integer, default: 1
  
  validates :occurrences, numericality: true, presence: true
  validate :occurrences_greater_than_zero
  
  private
  def occurrences_greater_than_zero
    errors[:base] << "Required action occurrences must be greater than zero" if occurrences == 0
  end
  
end
