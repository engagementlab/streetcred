class RequiredAction
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :award
  belongs_to :action_type
  
  field :name, type: String
  field :occurences, type: Integer, default: 1
  
  validates :occurences, numericality: true, presence: true
  validate :occurences_greater_than_zero
  
  private
  def occurences_greater_than_zero
    errors[:base] << "Required action occurences must be greater than zero" if occurences == 0
  end
  
end
