class User
  include Mongoid::Document
  field :email, type: String
  field :provider, type: String
  field :uid, type: String
  field :token, type: String
  field :omnitoken, type: String
  field :omnitoken_expires_at, type: Time
  field :name, type: String
  field :level, type: Integer
  # :anonymous=0, :user=2, robot=4, moderator=8, admin=10
  field :privacy_settings, type: Hash, default: {show_FB: true, list_comments: true}
  field :noti_settings, type: Hash, default: { NewComment: false, NewLike: false, NewDislike: false,
        NewOppose: true, NewSupport: true, Announcement: true, Other: false }

  field :allow_show_FB, type: Boolean, default: true
  field :allow_list_comments, type: Boolean, default: true

  has_and_belongs_to_many :subscriptions, class_name: "Topic", inverse_of: :subscribed_by, autosave: true
  has_many :proxies, class_name: "Proxy", inverse_of: :user, autosave: true, dependent: :destroy
  has_many :notifications, class_name: "Notification", inverse_of: :target, autosave: true, dependent: :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      if auth['info']
        user.name = auth['info']['name'] || ""
      end
      user.omnitoken = auth[:credentials][:token]
      user.omnitoken_expires_at = Time.at(auth[:credentials][:expires_at])
    end
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(omnitoken)
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
  #before_save :generate_token
  def generate_token
    self.token = SecureRandom.urlsafe_base64
  end

  def comment_count
    total_count = 0
    self.proxies.each do |proxy|
      total_count += proxy.works.count
    end
    return total_count
  end

  def like_count
    total_count = 0
    self.proxies.each do |proxy|
      total_count += proxy.approvals.count
    end
    return total_count
  end

  def dislike_count
    total_count = 0
    self.proxies.each do |proxy|
      total_count += proxy.disapprovals.count
    end
    return total_count
  end

  def read_comments_count
    total_count = 0
    self.proxies.each do |proxy|
      total_count += proxy.read_comments.count
    end
    return total_count
  end

  def is_robot?
    return self.id.to_s == "aaaaaaaaaaaaaaaaaaaaaaaa"
  end
end
