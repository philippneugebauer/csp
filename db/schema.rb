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

ActiveRecord::Schema[8.1].define(version: 2026_02_14_164231) do
  create_table "customer_email_messages", force: :cascade do |t|
    t.text "body_text"
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.integer "customer_success_manager_id", null: false
    t.integer "direction", default: 0, null: false
    t.string "from_email"
    t.string "gmail_message_id", null: false
    t.string "gmail_thread_id"
    t.json "metadata", default: {}
    t.datetime "sent_at"
    t.text "snippet"
    t.string "subject"
    t.string "to_email"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_email_messages_on_customer_id"
    t.index ["customer_success_manager_id"], name: "index_customer_email_messages_on_customer_success_manager_id"
    t.index ["gmail_message_id"], name: "index_customer_email_messages_on_gmail_message_id", unique: true
    t.index ["gmail_thread_id"], name: "index_customer_email_messages_on_gmail_thread_id"
    t.index ["sent_at"], name: "index_customer_email_messages_on_sent_at"
  end

  create_table "customer_notes", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.integer "customer_success_manager_id", null: false
    t.datetime "noted_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_notes_on_customer_id"
    t.index ["customer_success_manager_id"], name: "index_customer_notes_on_customer_success_manager_id"
    t.index ["noted_at"], name: "index_customer_notes_on_noted_at"
  end

  create_table "customer_success_managers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.integer "churn_risk", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "customer_success_manager_id", null: false
    t.string "name", null: false
    t.string "primary_contact_email", null: false
    t.integer "stage", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_success_manager_id"], name: "index_customers_on_customer_success_manager_id"
    t.index ["primary_contact_email"], name: "index_customers_on_primary_contact_email"
  end

  add_foreign_key "customer_email_messages", "customer_success_managers"
  add_foreign_key "customer_email_messages", "customers"
  add_foreign_key "customer_notes", "customer_success_managers"
  add_foreign_key "customer_notes", "customers"
  add_foreign_key "customers", "customer_success_managers"
end
