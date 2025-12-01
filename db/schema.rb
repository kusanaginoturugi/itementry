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

ActiveRecord::Schema[8.1].define(version: 2025_12_01_115805) do
  create_table "items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "item_code", default: "", null: false
    t.text "name", null: false
    t.datetime "updated_at", null: false
    t.integer "value", null: false
    t.index ["item_code"], name: "index_items_on_item_code", unique: true
  end

  create_table "receipt_details", force: :cascade do |t|
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.text "item_code", default: "", null: false
    t.integer "item_id", null: false
    t.text "item_name"
    t.integer "receipt_id", null: false
    t.integer "sum_value", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 0, null: false
    t.index ["item_code"], name: "index_receipt_details_on_item_code"
    t.index ["item_id"], name: "index_receipt_details_on_item_id"
    t.index ["receipt_id"], name: "index_receipt_details_on_receipt_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "name"
    t.integer "total_count", default: 0, null: false
    t.integer "total_value", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "receipt_details", "items"
  add_foreign_key "receipt_details", "receipts"
end
