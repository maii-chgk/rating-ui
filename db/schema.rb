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

ActiveRecord::Schema.define(version: 2021_08_23_195216) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "models", force: :cascade do |t|
    t.text "name"
    t.boolean "changes_teams"
    t.boolean "changes_rosters"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["name"], name: "index_models_on_name", unique: true
  end

  create_table "rating_country", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "title", limit: 100
    t.integer "r_id"
  end

  create_table "rating_player", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.integer "r_id"
    t.string "patronymic", limit: 100
  end

  create_table "rating_result", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.text "mask"
    t.string "team_title", limit: 250
    t.integer "total"
    t.integer "position"
    t.integer "syncrequest_id"
    t.integer "team_id"
    t.text "flags"
    t.integer "tournament_id"
  end

  create_table "rating_team", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "title", limit: 250
    t.integer "r_id"
    t.integer "town_id"
  end

  create_table "rating_tournament", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "title", limit: 100
    t.integer "r_id"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.json "questionQty"
    t.integer "typeoft_id"
  end

  create_table "rating_town", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "title", limit: 100
    t.integer "r_id"
    t.integer "country_id"
    t.integer "region_id"
  end

end
