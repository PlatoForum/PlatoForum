class Topic
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :permalink, type: String

  has_many :comments, class_name: "Comment", inverse_of: :target, autosave: true, validate: false
  has_many :stances
  has_many :proxies

  validates :name, presence: true
  #validates :description, presence: true
  validates_presence_of :permalink
  validates_uniqueness_of :permalink
  validates_format_of :permalink, :with => /\A\w+\z/
end