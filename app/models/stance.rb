class Stance
  include Mongoid::Document

  field :number, type: Integer
  field :description, type: String
  field :panel, type: String

  has_many :comments, class_name: "Comment", inverse_of: :stance, autosave: true, dependent: :destroy, order: 'importance_factor DESC'

  belongs_to :topic, class_name: "Topic", inverse_of: :stances, autosave: true

  def display_description
  	return self.description.nil? ? "立場：" + self.comments[0].display_abstract_long : self.description
  end
  
end
