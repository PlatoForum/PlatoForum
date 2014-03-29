class Topic
  include Mongoid::Document
  field :description, type: String

  has_many :topics
  has_many :stances
end
