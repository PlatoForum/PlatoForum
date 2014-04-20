class Stance
  include Mongoid::Document

  field :number, type: Integer
  field :description, type: String
  field :panel, type: String
  field :keywords, type: Array

  has_many :comments, class_name: "Comment", inverse_of: :stance, autosave: true, dependent: :destroy, order: 'importance_factor DESC'

  belongs_to :topic, class_name: "Topic", inverse_of: :stances, autosave: true

  def display_description
  	return self.description.nil? ? self.comments[0].display_abstract : self.description
  	#return self.keywords.join('、')
  end
  
end
