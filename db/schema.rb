# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161123161827) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string   "name"
    t.string   "hash_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authors_items", id: false, force: :cascade do |t|
    t.integer "item_id"
    t.integer "author_id"
  end

  create_table "feed_sources", force: :cascade do |t|
    t.string  "name",   limit: 255
    t.text    "url"
    t.string  "slug"
    t.integer "key_id"
  end

  add_index "feed_sources", ["key_id"], name: "index_feed_sources_on_key_id", using: :btree

  create_table "feeds", force: :cascade do |t|
    t.integer  "feed_source_id"
    t.string   "url"
    t.integer  "status"
    t.datetime "expiration_date"
    t.string   "error_msg"
    t.boolean  "is_pubsubhubbub_supported"
  end

  create_table "items", force: :cascade do |t|
    t.integer  "feed_source_id"
    t.text     "url"
    t.text     "title"
    t.text     "summary"
    t.text     "guid"
    t.text     "author"
    t.text     "image"
    t.boolean  "sent_to_api",       default: false, null: false
    t.datetime "published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "rejected_by_api",   default: false
    t.json     "error"
    t.boolean  "image_thumbnail",   default: false, null: false
    t.text     "body"
    t.integer  "feed_id"
    t.boolean  "from_initial_sync", default: false, null: false
    t.integer  "lateral_id"
  end

  add_index "items", ["feed_id"], name: "index_items_on_feed_id", using: :btree
  add_index "items", ["feed_source_id", "guid"], name: "index_items_on_feed_source_id_and_guid", unique: true, using: :btree
  add_index "items", ["feed_source_id"], name: "index_items_on_feed_source_id", using: :btree
  add_index "items", ["lateral_id"], name: "index_items_on_lateral_id", using: :btree
  add_index "items", ["updated_at"], name: "items_updated_at_idx", using: :btree

  create_table "keys", force: :cascade do |t|
    t.string "key"
    t.string "endpoint"
    t.string "purpose"
  end

  add_foreign_key "feed_sources", "keys"
  add_foreign_key "items", "feeds"
end
