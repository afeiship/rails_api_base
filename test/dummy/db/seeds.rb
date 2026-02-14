# Create sample users
user1 = User.create!(name: "Alice", email: "alice@example.com")
user2 = User.create!(name: "Bob", email: "bob@example.com")

# Create sample posts
Post.create!(title: "First Post", content: "Hello World", status: "published", views: 100, user: user1)
Post.create!(title: "Second Post", content: "Rails is awesome", status: "published", views: 50, user: user1)
Post.create!(title: "Draft Post", content: "Work in progress", status: "draft", views: 0, user: user2)
Post.create!(title: "Archived Post", content: "Old content", status: "archived", views: 200, user: user2)

puts "Created #{User.count} users"
puts "Created #{Post.count} posts"
