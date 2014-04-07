class Topic
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :permalink, type: String
  field :doc, type: Time, default: Time.zone.now
  field :last_updated, type: Time
  field :topic_type, type: Integer
  # topic_type :yesno, :open

  has_many :comments, class_name: "Comment", inverse_of: :topic, autosave: true, validate: false
  has_many :stances, class_name: "Stance", inverse_of: :topic, autosave: true, validate: false
  has_many :proxies

  has_and_belongs_to_many :subscribed_by, class_name: "User", inverse_of: :subscriptions, autosave: true, validate: false

  validates :name, presence: true
  #validates :description, presence: true
  validates_presence_of :permalink
  validates_uniqueness_of :permalink
  validates_format_of :permalink, :with => /\A\w+\z/
  validates_length_of :name, :maximum => 10
  validates_presence_of :topic_type

  validates_presence_of :doc
end