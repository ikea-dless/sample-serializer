class PostCommentSerializer < ActiveModel::Serializer
  attributes :id, :body
  belongs_to :user
  belongs_to :post
end
