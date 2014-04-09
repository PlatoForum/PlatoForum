class Job
  include Mongoid::Document

  field :action, type: Symbol 
  # :like, :dislike, :unlike, :undislike, :create, :support, :oppose
  field :group, type: BSON::ObjectId
  field :who, type: BSON::ObjectId
  field :post, type: BSON::ObjectId
  field :target, type: BSON::ObjectId
  field :message, type: String
  field :toc, type: Time

  #validates_presence_of :action
  #validates_presence_of :group
  #validates_presence_of :who
  #validates_presence_of :post

  before_validation :time_stamping
  def time_stamping
    self.toc = Time.now
  end
end
