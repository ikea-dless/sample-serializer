class PostSerializer < ApplicationSerializer
  attributes :id, :title, :body

  belongs_to :user

  attribute :user_name do
    'user_name'
  end
end
