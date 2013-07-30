class Provider
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, index: true

 	field :provider, type: String
  field :provider_uid, type: String
  field :info, type: String
  field :credentials, type: String
  field :extra, type: String
end
