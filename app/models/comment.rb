class Comment
  include Mongoid::Document
  field :subject, type: String
  field :body, type: String
  field :doc, type: Time, default: Time.zone.now
  field :stance, type: Integer

  belongs_to :owner, class_name: "Proxy", inverse_of: :works, autosave: true
  belongs_to :target, class_name: "Topic", inverse_of: :comments, autosave: true
  belongs_to :stanceObj, class_name: "Stance", inverse_of: :comments, autosave:true

  has_and_belongs_to_many :likes, class_name: "Proxy", inverse_of: :approvals, validate: false
  has_and_belongs_to_many :dislikes, class_name: "Proxy", inverse_of: :disapprovals, validate: false

  validates_presence_of :owner
  validates_presence_of :doc

  validates :subject, presence: true
  validates :body, presence: true
  validates :stance, presence: true

  after_create :create_job
  def create_job
    @job = Job.new
    @job.group = self.target._id
    @job.who = self.owner._id
    @job.post = self._id
    @job.action = :create
    REDIS.publish "jobqueue", @job.to_json
  end
end
