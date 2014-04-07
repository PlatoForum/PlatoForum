class Stance
  include Mongoid::Document

  field :number, type: Integer
  field :description, type: String
  field :panel, type: String

  has_many :comments, class_name: "Comment", inverse_of: :stance, autosave: true

  belongs_to :topic, class_name: "Topic", inverse_of: :stances, autosave: true
  
end
