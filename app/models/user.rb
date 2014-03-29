class User
  include Mongoid::Document
  field :email, type: String
  field :provider, type: String
  field :uid, type: String
  field :name, type: String

  has_many :works, class_name: "Comment", inverse_of: :owner, autosave: true, validate: false
  has_and_belongs_to_many :approvals, class_name: "Comment", inverse_of: :likes, validate: false
  has_and_belongs_to_many :disapprovals, class_name: "Comment", inverse_of: :dislikes, validate: false

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      if auth['info']
        user.name = auth['info']['name'] || ""
      end
    end
  end
end
