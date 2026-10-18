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

ActiveRecord::Schema[7.0].define(version: 2023_09_13_014346) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_api_input_fields", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.string "default_value", null: false
    t.integer "ai_api_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "options", default: [], array: true
  end

  create_table "ai_apis", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "name", null: false
    t.string "model_list", default: [], array: true
    t.string "parameter_list", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ai_type", default: 0
  end

  create_table "chat_histories", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "chat_name", default: "New chat"
    t.integer "user_id", null: false
    t.text "chat_context", default: ""
    t.integer "default_models", default: 0
    t.json "metadata", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prompt_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "name", null: false
    t.string "address"
    t.integer "company_type", default: 0, null: false
    t.string "v_company_uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["v_company_uid"], name: "index_companies_on_v_company_uid", unique: true
  end

  create_table "keys", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "key_string", null: false
    t.string "note"
    t.datetime "valid_until"
    t.integer "prompt_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "used", default: false
  end

  create_table "logs", force: :cascade do |t|
    t.string "ip"
    t.string "user_agent"
    t.string "api_endpoint"
    t.text "api_body"
    t.string "ai_endpoint"
    t.text "ai_body"
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prompt_id"
    t.integer "project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "application_domain"
    t.string "ip_white_list"
    t.integer "company_id"
  end

  create_table "prompt_input_fields", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "name", null: false
    t.text "value", null: false
    t.integer "prompt_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
  end

  create_table "prompts", force: :cascade do |t|
    t.string "public_uid", null: false
    t.string "name", null: false
    t.integer "ai_api_id", null: false
    t.string "model"
    t.string "parameter_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "endpoint_name"
    t.integer "project_id"
    t.text "description"
    t.json "prompt_test_response"
    t.string "messages_params"
    t.string "functions_params"
    t.integer "user_id"
  end

  create_table "user_projects", force: :cascade do |t|
    t.string "public_uid", null: false
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 2
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", null: false
    t.string "public_uid", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.integer "role", default: 2
    t.integer "gender"
    t.integer "company_id"
    t.boolean "is_representative", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
