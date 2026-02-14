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

ActiveRecord::Schema[8.1].define(version: 2026_02_14_213000) do
  create_table "activities", force: :cascade do |t|
    t.text "body"
    t.text "body_text"
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.integer "customer_success_manager_id", null: false
    t.integer "direction"
    t.string "from_email"
    t.string "gmail_message_id"
    t.string "gmail_thread_id"
    t.json "metadata", default: {}
    t.datetime "occurred_at", null: false
    t.text "snippet"
    t.string "subject"
    t.string "to_email"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_activities_on_customer_id"
    t.index ["customer_success_manager_id"], name: "index_activities_on_customer_success_manager_id"
    t.index ["gmail_message_id"], name: "index_activities_on_gmail_message_id", unique: true
    t.index ["gmail_thread_id"], name: "index_activities_on_gmail_thread_id"
    t.index ["occurred_at"], name: "index_activities_on_occurred_at"
    t.index ["type"], name: "index_activities_on_type"
  end

  create_table "customer_contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "email"], name: "index_customer_contacts_on_customer_id_and_email"
    t.index ["customer_id"], name: "index_customer_contacts_on_customer_id"
  end

  create_table "customer_success_managers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_customer_success_managers_on_deleted_at"
    t.index ["email"], name: "index_customer_success_managers_on_email"
  end

  create_table "customers", force: :cascade do |t|
    t.integer "churn_risk", default: 0, null: false
    t.json "contact_persons", default: [], null: false
    t.date "contract_start_date"
    t.date "contract_termination_date"
    t.datetime "created_at", null: false
    t.integer "customer_segment", default: 3, null: false
    t.integer "customer_success_manager_id", null: false
    t.string "name", null: false
    t.string "organization_id"
    t.string "primary_contact_email"
    t.integer "stage", default: 0, null: false
    t.decimal "travel_budget", precision: 12, scale: 2
    t.datetime "updated_at", null: false
    t.index ["customer_segment"], name: "index_customers_on_customer_segment"
    t.index ["customer_success_manager_id"], name: "index_customers_on_customer_success_manager_id"
    t.index ["organization_id"], name: "index_customers_on_organization_id"
    t.index ["primary_contact_email"], name: "index_customers_on_primary_contact_email"
  end

  add_foreign_key "activities", "customer_success_managers"
  add_foreign_key "activities", "customers"
  add_foreign_key "customer_contacts", "customers"
  add_foreign_key "customers", "customer_success_managers"
end
