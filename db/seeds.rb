('A'..'Z').each { |char| User.create!(name: char) }
('A'..'H').each { |char| User.find_by(name: char).posts.create!(title: "title#{char}", body: "body#{char}") }
('A'..'H').each do |char|
  User.find_by(name: char).post_comments.create!(post: Post.all.sample, body: "body#{char}")
end