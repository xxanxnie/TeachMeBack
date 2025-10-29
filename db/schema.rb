ActiveRecord::Schema[8.1].define(version: 2025_10_29_000200) do
  create_table "skill_exchange_requests", force: :cascade do |t|
    t.integer "availability_mask", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "expires_after_days"
    t.integer "learn_level", default: 1, null: false
    t.string "learn_skill", null: false
    t.text "learning_goal"
    t.string "modality", default: "in_person", null: false
    t.text "notes"
    t.integer "offer_hours", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.integer "teach_level", default: 2, null: false
    t.string "teach_skill", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["status"], name: "index_skill_exchange_requests_on_status_and_visibility"
    t.index ["user_id"], name: "index_skill_exchange_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.boolean "edu_verified"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "location"
    t.string "name"
    t.string "password"
    t.string "password_digest"
    t.string "university"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "skill_exchange_requests", "users"
end
