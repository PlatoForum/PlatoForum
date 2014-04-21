class Stance
  include Mongoid::Document

  field :number, type: Integer
  field :description, type: String
  field :panel, type: String, default: "default"
  field :keywords, type: Array

  has_many :comments, class_name: "Comment", inverse_of: :stance, autosave: true, dependent: :destroy, order: 'importance_factor DESC'

  belongs_to :topic, class_name: "Topic", inverse_of: :stances, autosave: true

  def display_description
  	return self.description.nil? ? self.comments[0].display_abstract : self.description
  end

  def display_keywords
  	return self.keywords.join('、')
  end
  
  def color_name
    case self.panel
    when "default" then return "灰"
    when "success" then return "綠"
    when "danger" then return "紅"
    when "primary" then return "藍"
    when "warning" then return "黃"
    end
  end

  def color_code
    case self.panel
    when "default" then return "#f5f5f5"
    when "success" then return "#28b62c"
    when "danger" then return "#ff4136"
    when "primary" then return "#158cba"
    when "warning" then return "#ff851b"
    end
  end

  def color_inverse_code
    if self.panel == "default"
      return "#333333"
    else
      return "#ffffff"
    end
  end

end
