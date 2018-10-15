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

ActiveRecord::Schema.define(version: 2018_09_19_040116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "foursquare_id"
    t.string "name"
    t.string "short_name"
    t.string "roman"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["foursquare_id"], name: "index_categories_on_foursquare_id", unique: true
    t.index ["name"], name: "index_categories_on_name"
    t.index ["roman"], name: "index_categories_on_roman"
  end

  create_table "restaurant_pictures", force: :cascade do |t|
    t.string "foursquare_id"
    t.bigint "restaurant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prefix"
    t.string "suffix"
    t.index ["foursquare_id"], name: "index_restaurant_pictures_on_foursquare_id", unique: true
    t.index ["restaurant_id"], name: "index_restaurant_pictures_on_restaurant_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "foursquare_id"
    t.string "name"
    t.string "phone"
    t.string "twitter_id"
    t.string "facebook_id"
    t.string "instagram_id"
    t.decimal "lat", precision: 9, scale: 6
    t.decimal "lng", precision: 9, scale: 6
    t.string "address"
    t.string "foursquare_url"
    t.float "rating"
    t.integer "price"
    t.bigint "category_id"
    t.bigint "station_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_restaurants_on_category_id"
    t.index ["foursquare_id"], name: "index_restaurants_on_foursquare_id", unique: true
    t.index ["station_id"], name: "index_restaurants_on_station_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "name"
    t.string "roman"
    t.string "prefecture"
    t.decimal "lat", precision: 9, scale: 6
    t.decimal "lng", precision: 9, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lat", "lng"], name: "index_stations_on_lat_and_lng"
    t.index ["name"], name: "index_stations_on_name"
    t.index ["roman"], name: "index_stations_on_roman"
  end

  add_foreign_key "restaurant_pictures", "restaurants"
  add_foreign_key "restaurants", "categories"
  add_foreign_key "restaurants", "stations"
end
