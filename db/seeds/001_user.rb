return if User.count >= 4

User.create(email: 'admin@example.com', password: 'Aa@123456', name: 'Admin', role: :admin)
User.create(email: 'user1@example.com', password: 'Aa@123456', name: 'User 1', role: :member)
User.create(email: 'user2@example.com', password: 'Aa@123456', name: 'User 2', role: :member)
User.create(email: 'user3@example.com', password: 'Aa@123456', name: 'User 3', role: :member)
