class Town
  include Mongoid::Document
  field :name, type: String
  field :ran, type: Float
end
