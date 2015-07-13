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

ActiveRecord::Schema.define(version: 20150428103406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.string   "name",                                    limit: 255
    t.text     "domain_names"
    t.integer  "server_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ruby_version",                            limit: 255, default: "2.0.0-p195"
    t.string   "rails_environment",                       limit: 255, default: "production"
    t.string   "database_host",                           limit: 255, default: "localhost"
    t.string   "database_name",                           limit: 255
    t.string   "deploy_user",                             limit: 255, default: "deploy"
    t.binary   "database_user_encrypted"
    t.binary   "database_password_encrypted"
    t.boolean  "enable_ssl",                                          default: false
    t.integer  "connect_to_database_from_application_id"
    t.boolean  "use_database_from_other_application"
    t.text     "redirect_domain_names"
    t.text     "ssl_key"
    t.text     "ssl_cert"
    t.datetime "deleted_at"
    t.boolean  "deleting",                                            default: false
    t.integer  "client_max_body_size",                                default: 20
  end

  add_index "applications", ["deleted_at"], name: "index_applications_on_deleted_at", using: :btree

  create_table "backups", force: :cascade do |t|
    t.boolean  "enabled",                          default: false
    t.integer  "application_id"
    t.integer  "storage_type",                     default: 0
    t.string   "dropbox_api_key",      limit: 255
    t.string   "dropbox_api_secret",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "s3_access_key",        limit: 255
    t.string   "s3_secret_access_key", limit: 255
    t.string   "s3_bucket",            limit: 255
    t.string   "s3_region",            limit: 255, default: "eu-west-1"
  end

  add_index "backups", ["application_id"], name: "index_backups_on_application_id", using: :btree

  create_table "env_vars", force: :cascade do |t|
    t.integer  "application_id"
    t.string   "key",            limit: 255
    t.string   "value",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "onboardings", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "ruby_version",         limit: 255, default: "2.2.1", null: false
    t.integer  "db_type",                          default: 0,       null: false
    t.integer  "provider",                         default: 0,       null: false
    t.integer  "digitalocean_region",              default: 0,       null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "digitalocean_api_key", limit: 255
    t.string   "last_finished_step",   limit: 255
    t.integer  "user_id"
    t.integer  "server_id"
    t.integer  "application_id"
    t.binary   "rsa_key_encrypted"
    t.string   "ip",                   limit: 255
    t.integer  "port"
    t.string   "username",             limit: 255
  end

  add_index "onboardings", ["application_id"], name: "index_onboardings_on_application_id", using: :btree
  add_index "onboardings", ["server_id"], name: "index_onboardings_on_server_id", using: :btree
  add_index "onboardings", ["user_id"], name: "index_onboardings_on_user_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "stripe_id",       limit: 255
    t.string   "stripe_name",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stripe_amount"
    t.string   "stripe_currency", limit: 255
    t.datetime "deleted_at"
    t.boolean  "active"
    t.integer  "max_servers"
    t.boolean  "staff",                       default: false
  end

  create_table "servers", force: :cascade do |t|
    t.string   "name",                         limit: 255,                      null: false
    t.string   "address",                      limit: 255
    t.boolean  "bootstrapped"
    t.string   "username",                     limit: 255
    t.integer  "ssh_port",                                 default: 22
    t.integer  "owner_id",                                                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "ssh_deploy_keys"
    t.boolean  "working",                                  default: false
    t.string   "last_error",                   limit: 255
    t.binary   "rsa_key_encrypted"
    t.binary   "mysql_passwords_encrypted"
    t.boolean  "archived",                                 default: false
    t.datetime "applied_at"
    t.string   "stack",                        limit: 255, default: "rails"
    t.string   "applications_root",            limit: 255, default: "/u/apps"
    t.binary   "postgres_passwords_encrypted"
    t.string   "db_type",                      limit: 255, default: "postgres"
    t.string   "server_version",               limit: 255
    t.integer  "provider",                                 default: 0
    t.integer  "digitalocean_region",                      default: 0
    t.integer  "digitalocean_id"
    t.boolean  "wizard_finished",                          default: false
    t.boolean  "unattended_upgrades",                      default: false
  end

  create_table "ssh_keys", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "key"
    t.integer  "server_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.string   "stripe_customer_id",          limit: 255
    t.datetime "canceled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country",                     limit: 255
    t.string   "tin",                         limit: 255
    t.integer  "vat"
    t.string   "stripe_subscription_id",      limit: 255
    t.datetime "stripe_current_period_start"
    t.datetime "stripe_current_period_end"
    t.string   "stripe_status",               limit: 255
  end

  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                     limit: 255, default: "",    null: false
    t.string   "encrypted_password",        limit: 255, default: "",    null: false
    t.string   "reset_password_token",      limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
    t.string   "confirmation_token",        limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "staff",                                 default: false
    t.string   "digitalocean_access_token", limit: 255
    t.string   "stripe_customer_id",        limit: 255
    t.datetime "trial_started_at"
    t.string   "full_name",                 limit: 255
    t.boolean  "trial_message_shown",                   default: false
    t.boolean  "admin",                                 default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "onboardings", "applications"
  add_foreign_key "onboardings", "servers"
  add_foreign_key "onboardings", "users"
end
