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

ActiveRecord::Schema.define(version: 20140526042609) do

  create_table "fluentds", force: true do |t|
    t.string   "variant",                                          null: false
    t.string   "pid_file"
    t.string   "log_file"
    t.string   "config_file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "api_endpoint", default: "http://localhost:24220/"
  end

  create_table "login_tokens", force: true do |t|
    t.string   "token_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "login_tokens", ["token_id"], name: "index_login_tokens_on_token_id"

  create_table "users", force: true do |t|
    t.string   "name",            null: false
    t.string   "password_digest", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
