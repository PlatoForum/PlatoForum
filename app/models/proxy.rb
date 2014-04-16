class Proxy
  include Mongoid::Document
  after_initialize :init
  
  field :pseudonym, type: String # should change to some pseudonym generator
  field :real_id, type: Boolean
  
  belongs_to :user
  belongs_to :topic
  has_many :works, class_name: "Comment", inverse_of: :owner, autosave: true, validate: false
  has_and_belongs_to_many :approvals, class_name: "Comment", inverse_of: :likes, validate: false
  has_and_belongs_to_many :disapprovals, class_name: "Comment", inverse_of: :dislikes, validate: false
  has_and_belongs_to_many :read_comments, class_name: "Comment", inverse_of: :read_by, autosave: true

  validates_presence_of :user
  validates_presence_of :topic
  validates_uniqueness_of :pseudonym

  #def initialize(name)
  #  #self.pseudonym = pseudonym_generator()
  #  self.pseudonym = name
  #end

  def init
    self.real_id  ||= false          #will set the default value only if it's nil
  end

  def display_name
    if self.real_id
      return self.user.name
    else
      return self.pseudonym
    end
  end

  def display_link
    if self.real_id
      return "http://www.facebook.com/" + self.user.uid
    else
      return "/#{self.topic.permalink}/proxy_#{self.id}"
    end
  end

  def display_email
    if self.real_id
      return self.user.email
    else
      return "/#{self.topic.permalink}/proxy_#{self.id}"
    end
  end

  def is_robot?
    return self.user.id.to_s == "aaaaaaaaaaaaaaaaaaaaaaaa"
  end
 end
