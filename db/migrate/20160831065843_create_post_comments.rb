class CreatePostComments < ActiveRecord::Migration[5.0]
  def change
    create_table :post_comments do |t|
      t.references :post
      t.references :user
      t.string :body

      t.timestamps
    end
  end
end
