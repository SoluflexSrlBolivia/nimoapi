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

ActiveRecord::Schema.define(version: 20160728192636) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "aliases", force: :cascade do |t|
    t.string   "name"
    t.integer  "aliasable_id"
    t.string   "aliasable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "aliases", ["aliasable_type", "aliasable_id"], name: "index_aliases_on_aliasable_type_and_aliasable_id", using: :btree

  create_table "archives", force: :cascade do |t|
    t.text     "description"
    t.string   "original_file_name"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "uploader_id"
    t.integer  "archivable_id"
    t.string   "archivable_type"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "digital_file_name"
    t.string   "digital_content_type"
    t.integer  "digital_file_size"
    t.datetime "digital_updated_at"
  end

  add_index "archives", ["archivable_type", "archivable_id"], name: "index_archives_on_archivable_type_and_archivable_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "comment"
    t.string   "alias"
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree

  create_table "devices", force: :cascade do |t|
    t.string   "identifier"
    t.string   "idDevice"
    t.string   "version"
    t.string   "os"
    t.string   "model"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "downloads", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "folder_id"
    t.integer  "archive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "folders", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "folderable_id"
    t.string   "folderable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "folders", ["folderable_type", "folderable_id"], name: "index_folders_on_folderable_type_and_folderable_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "keyword"
    t.integer  "privacity",   default: 1
    t.integer  "admin_id"
    t.boolean  "deleted",     default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.text     "title"
    t.text     "message"
    t.integer  "notification_type"
    t.text     "action"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "post"
    t.text     "description"
    t.string   "alias"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "rate_archives", force: :cascade do |t|
    t.integer  "rate"
    t.integer  "user_id"
    t.integer  "archive_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rate_posts", force: :cascade do |t|
    t.integer  "rate"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.boolean  "notification", default: true
    t.integer  "rate",         default: 0
    t.string   "alias"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "gender"
    t.datetime "birthday"
    t.text     "occupation"
    t.string   "phone_number"
    t.string   "country"
    t.string   "subregion"
    t.boolean  "deleted",              default: false
    t.boolean  "notification",         default: true
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",                default: false
    t.string   "activation_digest"
    t.boolean  "activated",            default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_foreign_key "devices", "users"
  add_foreign_key "notifications", "users"
end
