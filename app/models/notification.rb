class Notification
  include Mongoid::Document
  
  field :noti_type, type: Symbol
  # :NewComment, :NewSupport, :NewOppose, :NewLike, :NewDislike

  field :source_id, type: String
  field :destination_id, type: String
  field :doc, type: Time, default: Time.zone.now
  #field :stance, type: Integer

  field :read, type: Boolean, default: false

  belongs_to :target, class_name: "User", inverse_of: :notifications, autosave: true

end
