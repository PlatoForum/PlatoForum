class User
  include Mongoid::Document
  field :email, type: String
  field :provider, type: String
  field :uid, type: String
  field :name, type: String

  has_and_belongs_to_many :subscriptions, class_name: "Topic", inverse_of: :subscribed_by, autosave: true
  has_many :read_comments, class_name: "Comment"
  has_many :proxies, class_name: "Proxy", inverse_of: :user, autosave: true

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
end
