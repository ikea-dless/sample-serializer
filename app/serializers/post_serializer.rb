class PostSerializer < ApplicationSerializer
  attributes :id, :title, :body

  belongs_to :user

  def body
    "special #{object.body}"
  end
end
