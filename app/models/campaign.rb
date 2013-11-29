class Campaign
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Slug

  has_and_belongs_to_many :actions, index: true
  has_and_belongs_to_many :messages, index: true
  has_and_belongs_to_many :users, index: true
  embeds_many :required_actions
  accepts_nested_attributes_for :required_actions, allow_destroy: true
    
  scope :active, -> { lt(start_time: Time.now).gt(end_time: Time.now).asc(:end_time) }
  scope :completed, -> { lt(end_time: Time.now).desc(:end_time) }

  validates_presence_of :name, :required_actions
  validate :required_actions_unique

  slug :name
  
  field :name, type: String
  field :short_description, type: String
  field :description, type: String
  field :required_individual_occurrences, type: Integer, :default => 1
  field :required_community_occurrences, type: Integer, :default => 1
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :latitude, type: BigDecimal
  field :longitude, type: BigDecimal
  field :radius, type: BigDecimal
  field :coordinates, type: Array
  field :all_actions_required, type: Boolean

  
  index({ name: 1 }, { unique: true})
  index({ start_time: 1 })
  index({ end_time: 1 })
  index({ coordinates: "2d" })
  index "required_actions.name" => 1

  before_save :set_coordinates

  if Rails.env == 'production'
    has_mongoid_attached_file :individual_badge, storage: :s3, url: ':s3_domain_url', path: '/:class/:attachment/:id_partition/:style/:filename', s3_protocol: 'https', s3_credentials: { bucket: ENV['AWS_BUCKET'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }, styles: { icon: '30x30#', badge: '100x150', large: '150x200>' }
    has_mongoid_attached_file :community_badge, storage: :s3, url: ':s3_domain_url', path: '/:class/:attachment/:id_partition/:style/:filename', s3_protocol: 'https', s3_credentials: { bucket: ENV['AWS_BUCKET'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }, styles: { icon: '30x30#', badge: '100x150', large: '150x200>' }
    has_mongoid_attached_file :badge_icon, storage: :s3, url: ':s3_domain_url', path: '/:class/:attachment/:id_partition/:style/:filename', s3_protocol: 'https', s3_credentials: { bucket: ENV['AWS_BUCKET'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }, styles: { icon: '30x30#', badge: '100x150', large: '150x200>' }
  else
    has_mongoid_attached_file :individual_badge, :url => "individual_badges/:style/:filename", :path => "#{Rails.root}/public/assets/individual_badges/:style/:filename", styles: { icon: '30x30#', badge: '100x150', large: '150x200>' }
    has_mongoid_attached_file :community_badge, :url => "community_badges/:style/:filename", :path => "#{Rails.root}/public/assets/community_badges/:style/:filename", styles: { icon: '30x30#', badge: '100x150', large: '150x200>' }
    has_mongoid_attached_file :badge_icon, :url => "badge_icon/:style/:filename", :path => "#{Rails.root}/public/assets/badge_icon/:style/:filename", styles: { icon: '30x30#', badge: '100x150', large: '150x200>' }
  end

  def self.completed_community_campaigns
    self.all.select {|x| x.requirements_met_by_community?}
  end

  def channels
    self.required_actions.collect {|x| x.action_type.try(:channel)}.uniq.compact
  end

  def required_action_types
    required_actions.collect {|x| x.action_type}
  end

  def active?
    if start_time.present? && end_time.present?
      start_time < Time.now && end_time > Time.now
    else
      false
    end
  end

  def self.current
    self.active.desc(:time_left).first
  end

  def time_left
    if end_time.present?
      end_time.to_i - Time.now.to_i
    end
  end


  ##### COMMUNITY CALCULATIONS #####

  def contributing_community_actions
    Action.in(action_type_id: required_actions.collect(&:action_type_id)).gt(created_at: start_time).lt(created_at: end_time)
  end

  def progress_by_community
    contributing_community_actions.count / required_community_occurrences.to_f
  end

  def requirements_met_by_community?
    if contributing_community_actions.count >= required_community_occurrences
      if radius.blank?
        return true
      elsif radius.present?
        radius_exceeded?(contributing_community_actions)
      end
    else # if contributing_community_actions < required_individual_occurrences
      return false
    end
  end


  ##### INDIVIDUAL CALCULATIONS #####

  def contributing_individual_actions(user)
    Action.in(action_type_id: required_actions.collect(&:action_type_id)).gt(created_at: start_time).lt(created_at: end_time).where(user_id: user.id)
  end

  def progress_by_individual(user)
    contributing_individual_actions(user).count / required_individual_occurrences.to_f
  end

  def requirements_met_by_individual?(user)
    if contributing_individual_actions(user).count >= required_individual_occurrences
      if all_actions_required?
        if required_action_types == (required_action_types & contributing_individual_actions(User.first).collect {|x| x.action_type})
          if radius.blank?
            return true
          elsif radius.present?
            radius_exceeded?(contributing_individual_actions(user))
          end
        else
          return false
        end
      else
        if radius.blank?
          return true
        elsif radius.present?
          radius_exceeded?(contributing_individual_actions(user))
        end
      end
    else # if contributing_indivudal_actions < required_individual_occurrences
      return false
    end
  end


  ##### REACH CALCULATIONS #####
  
  def actions_within_radius(actions, center_point)
    actions.within_circle(coordinates: [center_point, self.radius])
  end
  
  def radius_exceeded?(actions)
    if radius.present?
      # make sure the actions have coordinates
      # actions_with_coordinates = actions.exists(coordinates: true).ne(coordinates: nil)
      actions_with_coordinates = actions.exists(coordinates: true)
      if actions_with_coordinates.present?
        if latitude.present? && longitude.present?
          center_point = [longitude.to_f, latitude.to_f]
        else
          center_point = Geocoder::Calculations.geographic_center(actions_with_coordinates.collect {|x| x.coordinates})
        end
        max_distance = actions_with_coordinates.geo_near(center_point).spherical.distance_multiplier(3959).max_distance
        # make sure the distance exceeds the radius and that at least one action is within the circle
        max_distance > radius && actions_within_circle(actions_with_coordinates, center_point).present?
      else
        return false
      end
    else
      return false
    end
  end

  private
  
  def set_coordinates
    if self.latitude.present? && self.longitude.present?
      self.coordinates = [self.longitude.try(:to_f), self.latitude.try(:to_f)]
    else
      self.coordinates = nil
    end
  end
  
  def required_actions_unique
    errors[:base] << "Required actions can't contain duplicates" if required_actions.collect {|x| "#{x.action_type.try(:channel).try(:name)}-#{x.action_type.try(:name)}"}.uniq.length != required_actions.length
  end
  
end
