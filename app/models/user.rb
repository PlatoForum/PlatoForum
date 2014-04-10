class User
  include Mongoid::Document
  field :email, type: String
  field :provider, type: String
  field :uid, type: String
  field :token, type: String
  field :name, type: String
  field :level, type: Symbol
  # :anonymous, :user=2, robot=4, moderator=8, admin=10

  has_and_belongs_to_many :subscriptions, class_name: "Topic", inverse_of: :subscribed_by, autosave: true
  has_and_belongs_to_many :read_comments, class_name: "Comment", inverse_of: :read_by, autosave: true
  has_many :proxies, class_name: "Proxy", inverse_of: :user, autosave: true
  has_many :notifications, class_name: "Notification", inverse_of: :target, autosave: true

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      if auth['info']
        user.name = auth['info']['name'] || ""
      end
    end
  end

  #def get_proxy_by_topic(topic_id)
  #  self.proxies.each do |p|
  #    return p if p.topic._id == topic_id
  #  end
  #  @pn = Proxy.new 
  #  @pn.topic = Topic.find_by(:id => topic_id)
  #  self.proxies << @pn
  #  @pn.save!
  #  return pn
  #end
  before_save :generate_token
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end
end
