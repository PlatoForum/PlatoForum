# encoding: UTF-8

class Comment
  include Mongoid::Document
  field :subject, type: String
  field :body, type: String
  field :doc, type: Time, default: Time.zone.now
  field :importance_factor, type: Integer, default: 0
  #field :importance_factor, type: Integer
  #field :stance, type: Integer
  field :tag, type: String
  field :tag_url, type: String

  belongs_to :owner, class_name: "Proxy", inverse_of: :works, autosave: true
  belongs_to :topic, class_name: "Topic", inverse_of: :comments, autosave: true
  belongs_to :stance, class_name: "Stance", inverse_of: :comments, autosave:true

  has_and_belongs_to_many :likes, class_name: "Proxy", inverse_of: :approvals, validate: false
  has_and_belongs_to_many :dislikes, class_name: "Proxy", inverse_of: :disapprovals, validate: false

  has_and_belongs_to_many :supporting, class_name: "Comment", inverse_of: :supported, validate: false
  has_and_belongs_to_many :opposing, class_name: "Comment", inverse_of: :opposed, validate: false

  has_and_belongs_to_many :supported, class_name: "Comment", inverse_of: :supporting, validate: false
  has_and_belongs_to_many :opposed, class_name: "Comment", inverse_of: :opposing, validate: false

  has_and_belongs_to_many :read_by, class_name: "Proxy", inverse_of: :read_comments

  validates_presence_of :owner
  validates_presence_of :doc

  validates :body, presence: true
  validates :stance, presence: true
  validates_length_of :subject, :maximum => 20

  after_create :create_job
  def create_job
    if self.topic.topic_type == :yesno
      return true
    end
    @job = Job.new
    @job.group = self.topic._id
    @job.who = self.owner._id
    @job.post = self._id
    @job.action = :create
    REDIS.publish "jobqueue", @job.to_json
    return true
  end

  def display_body_short
    return body.length > 60 ? self.body[0,60] + "⋯⋯" : self.body
  end

  def display_abstract
    if self.subject.nil? || self.subject.empty?
      return body.length > 20 ? self.body[0,20] + "⋯⋯" : self.body
    else
      return self.subject + "⋯⋯"
    end  
  end

  def display_abstract_long
    if self.subject.nil? || self.subject.empty?
      return body.length > 60 ? self.body[0,60] + "⋯⋯" : self.body
    else
      return self.subject + "⋯⋯"
    end
  end

  def display_time
    if self.doc.strftime("%F") == Time.zone.now.strftime("%F")
      return "今天 #{self.doc.strftime("%T")}"
    else
      return self.doc.strftime("%F")
    end
  end

  def display_time_detailed
    if self.doc.strftime("%F") == Time.zone.now.strftime("%F")
      return "今天 #{self.doc.strftime("%T")}"
    else
      return self.doc.strftime("%F %T")
    end
  end

  def update_importance_factor
    self.importance_factor = 2 * self.likes.count + self.dislikes.count + 2 * self.supported.count + self.opposed.count
  end
end
