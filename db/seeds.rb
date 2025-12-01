# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create test user
u = User.first || User.create!(
  name: "Test User",
  email: "test@school.edu",
  password: "password"
)

# Piano → Python
SkillExchangeRequest.find_or_create_by!(
  user: u,
  teach_skill: "Piano",
  learn_skill: "Python"
) do |r|
  r.teach_category = "music_art"
  r.learn_category = "tech_academics"
  r.teach_level = :intermediate
  r.learn_level = :beginner
  r.offer_hours = 2
  r.modality = "remote"
  r.expires_after_days = 30
  r.availability_days = [1, 2, 3] # Mon, Tue, Wed
  r.notes = "Beginner-friendly"
  r.learning_goal = "Learn the basics"
end

# Java → Spanish
SkillExchangeRequest.find_or_create_by!(
  user: u,
  teach_skill: "Java",
  learn_skill: "Spanish"
) do |r|
  r.teach_category = "tech_academics"
  r.learn_category = "language"
  r.teach_level = :advanced
  r.learn_level = :beginner
  r.offer_hours = 3
  r.modality = "hybrid"
  r.expires_after_days = 60
  r.availability_days = [5, 6] # Fri, Sat
  r.notes = "Weekend sessions"
end
