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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120501030829) do

  create_table "builds", :force => true do |t|
    t.integer  "warning_count"
    t.integer  "repository_id"
    t.string   "aasm_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_commit_id"
    t.text     "last_commit_message"
    t.integer  "position"
    t.integer  "duration",            :default => 0
    t.datetime "finished_at"
    t.string   "branch",              :default => "master", :null => false
  end

  add_index "builds", ["repository_id"], :name => "index_builds_on_repository_id"

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "configurations", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "url"
    t.integer "category_id"
  end

  add_index "configurations", ["category_id"], :name => "index_configurations_on_category_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "parameters", :force => true do |t|
    t.string  "name"
    t.string  "kind"
    t.string  "value"
    t.string  "description"
    t.integer "configuration_id"
  end

  add_index "parameters", ["configuration_id"], :name => "index_parameters_on_configuration_id"

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "repositories", :force => true do |t|
    t.string   "git_url"
    t.string   "name"
    t.string   "description"
    t.boolean  "private"
    t.boolean  "fork"
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "github_id"
    t.string   "html_url"
    t.string   "ssh_url"
    t.string   "github_name"
    t.integer  "builds_count",         :default => 0
    t.string   "authentication_token"
    t.boolean  "visible",              :default => false, :null => false
    t.string   "update_configs_url"
    t.integer  "collaborators_count",  :default => 0,     :null => false
    t.datetime "last_build_at"
  end

  create_table "user_repositories", :force => true do |t|
    t.integer "user_id"
    t.integer "repository_id"
    t.boolean "own",           :default => true
  end

  add_index "user_repositories", ["repository_id"], :name => "index_user_repositories_on_repository_id"
  add_index "user_repositories", ["user_id"], :name => "index_user_repositories_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "github_uid"
    t.string   "nickname"
    t.string   "name"
    t.string   "github_token"
    t.integer  "own_repositories_count",                :default => 0,     :null => false
    t.boolean  "admin",                                 :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
