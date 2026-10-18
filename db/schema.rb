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

ActiveRecord::Schema[7.1].define(version: 2026_10_18_050616) do
  create_table "challenge_answers", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "challenge_id", null: false
    t.text "submitted_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "passed", default: false, null: false
    t.index ["user_id", "challenge_id"], name: "index_challenge_answers_on_user_id_and_challenge_id", unique: true
    t.index ["user_id"], name: "index_challenge_answers_on_user_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "position"
    t.integer "journey_id", null: false
    t.string "challengeable_type", null: false
    t.integer "challengeable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challengeable_type", "challengeable_id"], name: "index_challenges_on_challengeable"
    t.index ["journey_id"], name: "index_challenges_on_journey_id"
  end

  create_table "journeys", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "minitest_test_classes", force: :cascade do |t|
    t.string "class_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "minitest_test_methods", force: :cascade do |t|
    t.string "method_name"
    t.text "method_body"
    t.integer "minitest_test_class_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.index ["minitest_test_class_id"], name: "index_minitest_test_methods_on_minitest_test_class_id"
  end

  create_table "recovery_codes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "code", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recovery_codes_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.boolean "otp_required_for_sign_in", default: false, null: false
    t.string "otp_secret", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_sign_in_at"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "challenge_answers", "challenges"
  add_foreign_key "challenge_answers", "users"
  add_foreign_key "challenges", "journeys"
  add_foreign_key "minitest_test_methods", "minitest_test_classes"
  add_foreign_key "recovery_codes", "users"
  add_foreign_key "sessions", "users"
end
