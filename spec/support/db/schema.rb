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

ActiveRecord::Schema.define(version: 20160427202553) do

  create_table "authors", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bad_guys", force: :cascade do |t|
    t.string   "nickname",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "books", force: :cascade do |t|
    t.integer  "author_id",  limit: 4
    t.string   "title",      limit: 255
    t.integer  "year",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["author_id"], name: "fk_rails_53d51ce16a", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "stars",      limit: 4
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "book_id",    limit: 4
    t.integer  "author_id",  limit: 4
  end

  add_index "reviews", ["author_id"], name: "index_reviews_on_author_id", using: :btree
  add_index "reviews", ["book_id"], name: "index_reviews_on_book_id", using: :btree

  add_foreign_key "books", "authors"
  add_foreign_key "reviews", "authors"
  add_foreign_key "reviews", "books"
end
