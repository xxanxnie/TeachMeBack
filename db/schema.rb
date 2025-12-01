# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_01_231752) do
  create_table "matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "mutual", null: false
    t.datetime "updated_at", null: false
    t.integer "user1_id", null: false
    t.integer "user2_id", null: false
    t.index ["user1_id", "user2_id"], name: "index_matches_on_user1_id_and_user2_id", unique: true
    t.index ["user1_id"], name: "index_matches_on_user1_id"
    t.index ["user2_id", "user1_id"], name: "index_matches_on_user2_id_and_user1_id"
    t.index ["user2_id"], name: "index_matches_on_user2_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.integer "recipient_id", null: false
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id", "sender_id", "created_at"], name: "index_messages_on_recipient_id_and_sender_id_and_created_at"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id", "recipient_id", "created_at"], name: "index_messages_on_sender_id_and_recipient_id_and_created_at"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "match_id"
    t.integer "rating", null: false
    t.integer "reviewee_id", null: false
    t.integer "reviewer_id", null: false
    t.integer "skill_exchange_request_id", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id", "reviewer_id"], name: "index_reviews_on_match_id_and_reviewer_id", unique: true
    t.index ["match_id"], name: "index_reviews_on_match_id"
    t.index ["reviewee_id"], name: "index_reviews_on_reviewee_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["skill_exchange_request_id"], name: "index_reviews_on_skill_exchange_request_id"
  end

  create_table "skill_exchange_requests", force: :cascade do |t|
    t.integer "availability_mask", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "expires_after_days"
    t.string "learn_category"
    t.integer "learn_level", default: 1, null: false
    t.string "learn_skill", null: false
    t.text "learning_goal"
    t.string "modality", default: "in_person", null: false
    t.text "notes"
    t.integer "offer_hours", default: 1, null: false
    t.integer "partner_id"
    t.integer "status", default: 0, null: false
    t.string "teach_category"
    t.integer "teach_level", default: 2, null: false
    t.string "teach_skill", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["status"], name: "index_skill_exchange_requests_on_status_and_visibility"
    t.index ["user_id"], name: "index_skill_exchange_requests_on_user_id"
  end

  create_table "user_skill_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "receiver_id", null: false
    t.integer "requester_id", null: false
    t.string "skill", null: false
    t.integer "skill_exchange_request_id"
    t.datetime "updated_at", null: false
    t.index ["receiver_id", "requester_id"], name: "index_user_skill_requests_on_receiver_id_and_requester_id"
    t.index ["receiver_id"], name: "index_user_skill_requests_on_receiver_id"
    t.index ["requester_id", "receiver_id", "skill_exchange_request_id"], name: "idx_usr_requests_on_requester_receiver_ser", unique: true
    t.index ["requester_id", "receiver_id"], name: "index_user_skill_requests_on_requester_id_and_receiver_id"
    t.index ["requester_id"], name: "index_user_skill_requests_on_requester_id"
    t.index ["skill_exchange_request_id"], name: "index_user_skill_requests_on_skill_exchange_request_id"
  end

  create_table "users", force: :cascade do |t|
    t.float "avg_rating"
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
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "matches", "users", column: "user1_id"
  add_foreign_key "matches", "users", column: "user2_id"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "reviews", "matches"
  add_foreign_key "reviews", "skill_exchange_requests"
  add_foreign_key "reviews", "users", column: "reviewee_id"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "skill_exchange_requests", "users"
  add_foreign_key "skill_exchange_requests", "users", column: "partner_id"
  add_foreign_key "user_skill_requests", "skill_exchange_requests"
  add_foreign_key "user_skill_requests", "users", column: "receiver_id"
  add_foreign_key "user_skill_requests", "users", column: "requester_id"
end
