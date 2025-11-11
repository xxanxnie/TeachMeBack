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

ActiveRecord::Schema[8.1].define(version: 2025_11_10_234659) do
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
    t.integer "status", default: 0, null: false
    t.string "teach_category"
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
