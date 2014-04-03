class Proxy
  include Mongoid::Document
  
  field :pseudonym, type: String # should change to some pseudonym generator
  
  belongs_to :user
  belongs_to :topic
  has_many :works, class_name: "Comment", inverse_of: :owner, autosave: true, validate: false
  has_and_belongs_to_many :approvals, class_name: "Comment", inverse_of: :likes, validate: false
  has_and_belongs_to_many :disapprovals, class_name: "Comment", inverse_of: :dislikes, validate: false

  validates_presence_of :user
  validates_presence_of :topic
  validates_uniqueness_of :pseudonym

  #def initialize(name)
  #  #self.pseudonym = pseudonym_generator()
  #  self.pseudonym = name
  #end

 end
