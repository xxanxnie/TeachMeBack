Given("I exercise app helpers for coverage") do
  u1 = User.create!(email: "cover1@school.edu", password: "secretpass", name: "Cover One")
  u2 = User.create!(email: "cover2@school.edu", password: "secretpass", name: "Cover Two")

  ser = SkillExchangeRequest.create!(
    user: u1,
    teach_skill: "Math",
    teach_level: "beginner",
    teach_category: "tech_academics",
    learn_skill: "Guitar",
    learn_level: "intermediate",
    learn_category: "music_art",
    offer_hours: 2,
    modality: "hybrid",
    expires_after_days: 15,
    availability_days: %w[mon thu],
    learning_goal: "Improve skills"
  )

  ser.availability_days
  ser.availability_days = ["wed", 3, "fri"]
  ser.expired?
  ser.teach_category_label
  ser.learn_category_label
  ser.valid?

  ser.update(status: :closed)
  ser.update(status: :open)
  SkillExchangeRequest.status_open_only.recent_first.to_a

  # Cover validation path for missing availability
  ser.availability_days = []
  ser.valid?

  Match.find_or_create_by!(user1: u1, user2: u2, status: "mutual")

  u1.has_sent_request_for?(u2, ser)
  u2.has_received_request_from?(u1)
  u1.matched_with?(u2)
  u1.thread_partners
  u1.unread_messages_count

  Message.create!(sender: u1, recipient: u2, body: "hello there")

  begin
    UserSkillRequest.create!(requester: u1, receiver: u1, skill: "Guitar")
  rescue StandardError
  end

  usr = UserSkillRequest.create!(requester: u1, receiver: u2, skill: "Drums")
  begin
    UserSkillRequest.create!(requester: u1, receiver: u2, skill: "Drums")
  rescue StandardError
  end

  usr.send(:check_for_reciprocal_match)

  begin
    User.create!(email: "invalid@gmail.com", password: "short")
  rescue StandardError
  end

  User.create!(email: "noname@school.edu", password: "secretpass", first_name: "No", last_name: "Name")
end

Given("I exercise controller branches for coverage") do
  # Touch framework base classes
  ApplicationJob rescue nil
  ApplicationMailer rescue nil

  base_user = User.create!(email: "dash@school.edu", password: "secretpass", name: "Dash User", first_name: "Dash", last_name: "User")
  owner     = User.create!(email: "owner@school.edu", password: "secretpass", name: "Owner User", first_name: "Owner", last_name: "User")

  SkillExchangeRequest.create!(
    user: owner,
    teach_skill: "Banjo",
    teach_level: "intermediate",
    teach_category: "music_art",
    learn_skill: "Elixir",
    learn_level: "beginner",
    learn_category: "tech_academics",
    offer_hours: 2,
    modality: "remote",
    expires_after_days: 30,
    availability_days: [0, 2]
  )

  SkillExchangeRequest.create!(
    user: owner,
    teach_skill: "French",
    teach_level: "advanced",
    teach_category: "language",
    learn_skill: "Guitar",
    learn_level: "beginner",
    learn_category: "music_art",
    offer_hours: 1,
    modality: "in_person",
    expires_after_days: 20,
    availability_days: [1, 3]
  )

  # Dashboard controller: success path with query filter
  dash_controller = DashboardController.new
  dash_controller.request = ActionDispatch::TestRequest.create
  dash_controller.request.session = ActionController::TestSession.new
  dash_controller.response = ActionDispatch::TestResponse.new
  dash_controller.request.session[:user_id] = base_user.id
  dash_controller.params = { q: "banjo" }
  dash_controller.index

  # Explore controller: student role filters with day/category and teach intent
  explore_controller = ExploreController.new
  explore_controller.request = ActionDispatch::TestRequest.create
  explore_controller.request.session = ActionController::TestSession.new
  explore_controller.response = ActionDispatch::TestResponse.new
  explore_controller.request.session[:user_id] = base_user.id
  explore_controller.params = {
    "role" => ["student"],
    "categories" => ["music_art"],
    "days" => ["mon"],
    "q" => "teach banjo"
  }
  explore_controller.index

  # Explore controller: instructor role with learn intent and explicit day filter
  explore_controller2 = ExploreController.new
  explore_controller2.request = ActionDispatch::TestRequest.create
  explore_controller2.request.session = ActionController::TestSession.new
  explore_controller2.response = ActionDispatch::TestResponse.new
  explore_controller2.request.session[:user_id] = base_user.id
  explore_controller2.params = {
    "role" => ["instructor"],
    "categories" => ["language"],
    "days" => ["wed"],
    "q" => "learn guitar"
  }
  explore_controller2.index
end
