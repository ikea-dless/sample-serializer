class PostSerializer < ApplicationSerializer
  attributes :id, :title, :body

  belongs_to :user do
    Comment.new(name: 'hoge')
  end

  def body
    "special #{object.body}"
  end
end
