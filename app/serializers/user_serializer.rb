class UserSerializer < ApplicationSerializer
  attributes :id, :name
  has_many :posts

  attribute :name do
    object.name << "hoge"
  end
end
