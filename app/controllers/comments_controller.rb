class CommentsController < ApplicationController
  def index
    @post_comments = PostComment.preload(:user, :post)
    render json: @post_comments, meta: { count: @post_comments.count }, meta_key: "memeta"
  end
end
