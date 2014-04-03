class Adjective
  include Mongoid::Document
  field :word, type: String
  field :ran, type: Float
end
