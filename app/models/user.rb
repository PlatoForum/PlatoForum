class User
  include Mongoid::Document
  field :email, type: String
  field :provider, type: String
  field :uid, type: String
  field :name, type: String

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
<<<<<<< HEAD
      if auth['info']
        user.name = auth['info']['name'] || ""
      end
=======
      user.name = auth["info"]["name"]
>>>>>>> ab80cdc0460e7e943428d96b893f3e79e424feb2
    end
  end
end
