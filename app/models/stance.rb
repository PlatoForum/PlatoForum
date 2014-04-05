class Stance
  include Mongoid::Document

  field :number, type: Integer
  field :description, type: String

  has_many :comments, class_name: "Comment", inverse_of: :stanceObj

  belongs_to :target, class_name: "Topic"
  
end
