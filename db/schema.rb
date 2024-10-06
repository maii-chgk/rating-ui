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

ActiveRecord::Schema[7.2].define(version: 2024_10_06_211401) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "models", force: :cascade do |t|
    t.text "name"
    t.boolean "changes_teams"
    t.boolean "changes_rosters"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["name"], name: "index_models_on_name", unique: true
  end

  create_table "true_dls", force: :cascade do |t|
    t.bigint "id"
    t.integer "tournament_id"
    t.float "true_dl"
    t.bigint "model_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.index ["model_id", "team_id", "tournament_id"], name: "index_true_dls_on_model_id_and_team_id_and_tournament_id", unique: true
    t.index ["model_id"], name: "index_true_dls_on_model_id"
  end

  create_table "wrong_team_ids", force: :cascade do |t|
    t.integer "tournament_id"
    t.integer "old_team_id"
    t.integer "new_team_id"
    t.datetime "updated_at"
  end

  add_foreign_key "true_dls", "models"
end
