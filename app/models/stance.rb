class Stance
  include Mongoid::Document

  field :number, type: Integer
  field :description, type: String

  has_many :comments, class_name: "Comment"

  belongs_to :topic
  
end
