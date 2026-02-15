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

ActiveRecord::Schema[8.1].define(version: 2026_02_15_141000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.text "body"
    t.text "body_text"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.integer "customer_success_manager_id", null: false
    t.integer "direction"
    t.string "from_email"
    t.string "gmail_message_id"
    t.string "gmail_thread_id"
    t.date "gmv_on"
    t.decimal "gmv_revenue", precision: 12, scale: 2
    t.json "metadata", default: {}
    t.datetime "occurred_at", null: false
    t.text "snippet"
    t.string "subject"
    t.string "to_email"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_at"], name: "index_activities_on_completed_at"
    t.index ["customer_id", "gmail_message_id"], name: "index_activities_on_customer_id_and_gmail_message_id", unique: true
    t.index ["customer_id"], name: "index_activities_on_customer_id"
    t.index ["customer_success_manager_id"], name: "index_activities_on_customer_success_manager_id"
    t.index ["gmail_thread_id"], name: "index_activities_on_gmail_thread_id"
    t.index ["gmv_on"], name: "index_activities_on_gmv_on"
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

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type"
    t.text "object", limit: 1073741823
    t.text "object_changes", limit: 1073741823
    t.string "whodunnit"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "customer_success_managers"
  add_foreign_key "activities", "customers"
  add_foreign_key "customer_contacts", "customers"
  add_foreign_key "customers", "customer_success_managers"
end
