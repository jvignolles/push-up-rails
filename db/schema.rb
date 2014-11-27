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

ActiveRecord::Schema.define(version: 20140902061600) do

  create_table "addresses", force: true do |t|
    t.string   "old_id",       limit: 36, default: "",   null: false
    t.string   "address",      limit: 64, default: "",   null: false
    t.string   "complement",   limit: 64, default: "",   null: false
    t.string   "zip_code",     limit: 16, default: "",   null: false
    t.string   "city_name",    limit: 64, default: "",   null: false
    t.integer  "city_id"
    t.string   "state_name",   limit: 64, default: "",   null: false
    t.string   "country_name", limit: 48, default: "",   null: false
    t.string   "country_code", limit: 2,  default: "FR", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["city_id"], name: "index_addresses_on_city_id", using: :btree
  add_index "addresses", ["city_name"], name: "index_addresses_on_city_name", using: :btree
  add_index "addresses", ["country_code"], name: "index_addresses_on_country_code", using: :btree
  add_index "addresses", ["created_at"], name: "index_addresses_on_created_at", using: :btree
  add_index "addresses", ["old_id"], name: "index_addresses_on_old_id", using: :btree
  add_index "addresses", ["zip_code"], name: "index_addresses_on_zip_code", using: :btree

  create_table "admins", force: true do |t|
    t.string   "old_id",                 limit: 36,  default: "",    null: false
    t.boolean  "active",                             default: true,  null: false
    t.string   "civility",               limit: 4,   default: "mr",  null: false
    t.string   "first_name",             limit: 64,  default: "",    null: false
    t.string   "last_name",              limit: 64,  default: "",    null: false
    t.string   "phone_home",             limit: 30,  default: "",    null: false
    t.string   "phone_mobile",           limit: 30,  default: "",    null: false
    t.string   "phone_work",             limit: 30,  default: "",    null: false
    t.string   "email",                  limit: 80,  default: "",    null: false
    t.string   "encrypted_password",     limit: 128, default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                    default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "admin",                              default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["confirmation_token"], name: "index_admins_on_confirmation_token", using: :btree
  add_index "admins", ["created_at"], name: "index_admins_on_created_at", using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", using: :btree
  add_index "admins", ["first_name", "last_name"], name: "index_admins_on_first_name_and_last_name", using: :btree
  add_index "admins", ["old_id"], name: "index_admins_on_old_id", using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", using: :btree
  add_index "admins", ["unlock_token"], name: "index_admins_on_unlock_token", using: :btree

  create_table "banners", force: true do |t|
    t.boolean  "active",                  default: true, null: false
    t.string   "name",        limit: 50,  default: "",   null: false
    t.string   "url",         limit: 128, default: "",   null: false
    t.string   "description",             default: "",   null: false
    t.string   "button",      limit: 50,  default: "",   null: false
    t.integer  "position",                default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "banners", ["created_at"], name: "index_banners_on_created_at", using: :btree
  add_index "banners", ["name"], name: "index_banners_on_name", using: :btree
  add_index "banners", ["position"], name: "index_banners_on_position", using: :btree

  create_table "cities", force: true do |t|
    t.boolean  "active",                                              default: true,  null: false
    t.boolean  "cedex",                                               default: false, null: false
    t.string   "country_code",   limit: 2,                            default: "FR",  null: false
    t.integer  "state_id"
    t.string   "zip_code",       limit: 16,                           default: "",    null: false
    t.string   "name",           limit: 50,                           default: "",    null: false
    t.decimal  "lat",                       precision: 15, scale: 10
    t.decimal  "lng",                       precision: 15, scale: 10
    t.boolean  "fake_city",                                           default: false, null: false
    t.string   "arrondissement", limit: 3,                            default: "",    null: false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["created_at"], name: "index_cities_on_created_at", using: :btree
  add_index "cities", ["state_id"], name: "index_cities_on_state_id", using: :btree
  add_index "cities", ["zip_code", "name"], name: "index_cities_on_zip_code_and_name", using: :btree

  create_table "configurations", force: true do |t|
    t.string   "app_name",                    limit: 128, default: "",    null: false
    t.string   "baseline",                                default: "",    null: false
    t.string   "email_contact",               limit: 128, default: "",    null: false
    t.string   "company_name",                limit: 128, default: "",    null: false
    t.string   "phone",                       limit: 20,  default: "",    null: false
    t.string   "phone_hours",                 limit: 128, default: "",    null: false
    t.string   "fax",                         limit: 20,  default: "",    null: false
    t.string   "address",                                 default: "",    null: false
    t.string   "siret",                       limit: 14,  default: "",    null: false
    t.string   "siren",                       limit: 9,   default: "",    null: false
    t.string   "intracom_vat_number",         limit: 32,  default: "",    null: false
    t.text     "quotation_description"
    t.text     "newsletter_description"
    t.string   "seo_title",                   limit: 128, default: "",    null: false
    t.string   "seo_description",                         default: "",    null: false
    t.text     "seo_keywords"
    t.boolean  "website_on_hold",                         default: false, null: false
    t.text     "website_on_hold_description"
    t.string   "facebook_url",                limit: 128, default: "",    null: false
    t.string   "twitter_url",                 limit: 128, default: "",    null: false
    t.string   "googleplus_url",              limit: 128, default: "",    null: false
    t.string   "instagram_url",               limit: 128, default: "",    null: false
    t.string   "pinterest_url",               limit: 128, default: "",    null: false
    t.string   "linkedin_url",                limit: 128, default: "",    null: false
    t.string   "viadeo_url",                  limit: 128, default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "name",             limit: 128, default: "",    null: false
    t.string   "email",            limit: 80,  default: "",    null: false
    t.string   "phone",            limit: 20,  default: "",    null: false
    t.boolean  "phone_ok",                     default: false, null: false
    t.string   "subject",          limit: 50,  default: "",    null: false
    t.text     "description"
    t.integer  "admin_id"
    t.datetime "answered_at"
    t.integer  "answerer_id"
    t.integer  "latest_answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["created_at"], name: "index_contacts_on_created_at", using: :btree
  add_index "contacts", ["name", "email"], name: "index_contacts_on_name_and_email", using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "countries", force: true do |t|
    t.string   "old_id",        limit: 36, default: "",   null: false
    t.boolean  "active",                   default: true, null: false
    t.string   "code",          limit: 2
    t.string   "name",          limit: 50, default: "",   null: false
    t.string   "english_name",  limit: 50, default: "",   null: false
    t.string   "currency_code", limit: 3
    t.boolean  "uses_vat",                 default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["code"], name: "index_countries_on_code", using: :btree
  add_index "countries", ["created_at"], name: "index_countries_on_created_at", using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", using: :btree
  add_index "countries", ["old_id"], name: "index_countries_on_old_id", using: :btree

  create_table "editorials", force: true do |t|
    t.boolean  "active",                      default: true, null: false
    t.boolean  "in_lateral_menu",             default: true, null: false
    t.string   "name",            limit: 128, default: "",   null: false
    t.string   "kind",            limit: 128, default: "",   null: false
    t.text     "text1"
    t.text     "text2"
    t.text     "text3"
    t.string   "seo_title",       limit: 128, default: "",   null: false
    t.string   "seo_h1",          limit: 128, default: "",   null: false
    t.string   "seo_description",             default: "",   null: false
    t.text     "seo_keywords"
    t.integer  "position",                    default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editorials", ["created_at"], name: "index_editorials_on_created_at", using: :btree
  add_index "editorials", ["kind"], name: "index_editorials_on_kind", using: :btree
  add_index "editorials", ["name"], name: "index_editorials_on_name", using: :btree
  add_index "editorials", ["position"], name: "index_editorials_on_position", using: :btree

  create_table "highlights", force: true do |t|
    t.boolean  "active",                  default: true, null: false
    t.string   "name",        limit: 50,  default: "",   null: false
    t.string   "url",         limit: 128, default: "",   null: false
    t.string   "description",             default: "",   null: false
    t.integer  "position",                default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "highlights", ["created_at"], name: "index_highlights_on_created_at", using: :btree
  add_index "highlights", ["name"], name: "index_highlights_on_name", using: :btree
  add_index "highlights", ["position"], name: "index_highlights_on_position", using: :btree

  create_table "images", force: true do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type", limit: 32
    t.string   "content_type",   limit: 32,                 null: false
    t.integer  "position",                  default: 0,     null: false
    t.boolean  "assisted",                  default: false, null: false
    t.string   "kind",           limit: 32
    t.boolean  "zoomable",                  default: false, null: false
    t.string   "img",                       default: "",    null: false
    t.text     "dimensions"
    t.string   "legend",                    default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["created_at"], name: "index_images_on_created_at", using: :btree
  add_index "images", ["imageable_id", "imageable_type"], name: "index_images_on_imageable_id_and_imageable_type", using: :btree
  add_index "images", ["kind"], name: "index_images_on_kind", using: :btree
  add_index "images", ["position"], name: "index_images_on_position", using: :btree

  create_table "products", force: true do |t|
    t.boolean  "active",                      default: true, null: false
    t.string   "name",            limit: 128, default: "",   null: false
    t.string   "price",           limit: 32,  default: "",   null: false
    t.text     "resume"
    t.text     "preview"
    t.text     "description"
    t.string   "seo_title",       limit: 128, default: "",   null: false
    t.string   "seo_h1",          limit: 128, default: "",   null: false
    t.string   "seo_description",             default: "",   null: false
    t.text     "seo_keywords"
    t.integer  "position",                    default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["created_at"], name: "index_products_on_created_at", using: :btree
  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["position"], name: "index_products_on_position", using: :btree

  create_table "quotations", force: true do |t|
    t.string   "first_name",       limit: 128, default: "", null: false
    t.string   "last_name",        limit: 80,  default: "", null: false
    t.string   "email",            limit: 128, default: "", null: false
    t.string   "phone",            limit: 20,  default: "", null: false
    t.string   "from_path"
    t.text     "description"
    t.integer  "product_id"
    t.integer  "admin_id"
    t.datetime "answered_at"
    t.integer  "answerer_id"
    t.integer  "latest_answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "quotations", ["created_at"], name: "index_quotations_on_created_at", using: :btree
  add_index "quotations", ["first_name", "last_name", "email"], name: "index_quotations_on_first_name_and_last_name_and_email", using: :btree

  create_table "regions", force: true do |t|
    t.boolean  "active",                  default: true, null: false
    t.string   "country_code", limit: 2,  default: "FR", null: false
    t.string   "name",         limit: 50, default: "",   null: false
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "regions", ["created_at"], name: "index_regions_on_created_at", using: :btree
  add_index "regions", ["name"], name: "index_regions_on_name", using: :btree

  create_table "states", force: true do |t|
    t.boolean  "active",                  default: true, null: false
    t.string   "country_code", limit: 2,  default: "FR", null: false
    t.integer  "region_id"
    t.string   "code",         limit: 16, default: "",   null: false
    t.string   "name",         limit: 50, default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "states", ["code"], name: "index_states_on_code", using: :btree
  add_index "states", ["created_at"], name: "index_states_on_created_at", using: :btree
  add_index "states", ["name"], name: "index_states_on_name", using: :btree
  add_index "states", ["region_id"], name: "index_states_on_region_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.string   "email",        limit: 128, null: false
    t.string   "kind",                     null: false
    t.string   "token",        limit: 10
    t.datetime "confirmation"
    t.datetime "revocation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["created_at"], name: "index_subscriptions_on_created_at", using: :btree
  add_index "subscriptions", ["email"], name: "index_subscriptions_on_email", using: :btree
  add_index "subscriptions", ["token"], name: "index_subscriptions_on_token", using: :btree

  create_table "team_members", force: true do |t|
    t.boolean  "active",                  default: true, null: false
    t.string   "civility",    limit: 4,   default: "mr", null: false
    t.string   "first_name",  limit: 128, default: "",   null: false
    t.string   "last_name",   limit: 128, default: "",   null: false
    t.text     "description"
    t.integer  "position",                default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_members", ["created_at"], name: "index_team_members_on_created_at", using: :btree
  add_index "team_members", ["first_name", "last_name"], name: "index_team_members_on_first_name_and_last_name", using: :btree
  add_index "team_members", ["position"], name: "index_team_members_on_position", using: :btree

  create_table "users", force: true do |t|
    t.string   "old_id",                 limit: 36,  default: "",   null: false
    t.boolean  "active",                             default: true, null: false
    t.string   "civility",               limit: 4,   default: "mr", null: false
    t.string   "first_name",             limit: 64,  default: "",   null: false
    t.string   "last_name",              limit: 64,  default: "",   null: false
    t.string   "phone_home",             limit: 30,  default: "",   null: false
    t.string   "phone_mobile",           limit: 30,  default: "",   null: false
    t.string   "phone_work",             limit: 30,  default: "",   null: false
    t.string   "email",                  limit: 80,  default: "",   null: false
    t.string   "encrypted_password",     limit: 128, default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                    default: 0,    null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", using: :btree
  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["first_name", "last_name"], name: "index_users_on_first_name_and_last_name", using: :btree
  add_index "users", ["old_id"], name: "index_users_on_old_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", using: :btree

end
