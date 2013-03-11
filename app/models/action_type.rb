class ActionType
  include Mongoid::Document
  
  has_and_belongs_to_many :awards
  
  field :name
  field :points, type: Integer, default: 0
  
  before_save :strip_name
  
  private
  
  def strip_name
    name.strip
  end
  
end
