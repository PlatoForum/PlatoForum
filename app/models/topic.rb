class Topic
  include Mongoid::Document
  field :description, type: String
  field :permalink, type: String

  has_many :topics
  has_many :stances
end
