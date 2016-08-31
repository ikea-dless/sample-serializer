class PostSerializer < ApplicationSerializer
  attributes :id, :title, :body

  belongs_to :user do
    Comment.new(name: 'hoge')
  end

  attribute :user_name do
    "user_name"
  end

end
