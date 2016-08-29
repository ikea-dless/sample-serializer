class PostsController < ApplicationController
  def index
    @posts = Post.all
    render json: @posts
    # comments = Comment.new(id: 1, name: 'hoge')
    # render json: comments, serializer: SampleSerializer, fields: [:name]
  end
end
