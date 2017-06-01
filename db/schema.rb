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

ActiveRecord::Schema.define(version: 20170627103857) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", id: :serial, force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "subject_id", null: false
    t.string "effect_type", null: false
    t.jsonb "config", default: {}, null: false
    t.integer "status", default: 0, null: false
    t.datetime "attempted_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_actions_on_subject_id"
    t.index ["workflow_id"], name: "index_actions_on_workflow_id"
  end

  create_table "classifications", id: :serial, force: :cascade do |t|
    t.jsonb "annotations", array: true
    t.integer "project_id"
    t.integer "workflow_id"
    t.integer "user_id"
    t.datetime "inserted_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.text "token", null: false
    t.string "refresh"
    t.datetime "expires_at", default: "2017-06-27 11:01:01", null: false
    t.integer "project_ids", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_credentials_on_token", unique: true
  end

  create_table "extracts", id: :serial, force: :cascade do |t|
    t.integer "classification_id"
    t.datetime "classification_at"
    t.string "extractor_id", null: false
    t.integer "project_id"
    t.integer "workflow_id"
    t.integer "user_id"
    t.integer "subject_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classification_id", "extractor_id"], name: "index_extracts_on_classification_id_and_extractor_id", unique: true
    t.index ["subject_id"], name: "index_extracts_on_subject_id"
    t.index ["user_id"], name: "index_extracts_on_user_id"
    t.index ["workflow_id"], name: "index_extracts_on_workflow_id"
  end

  create_table "reductions", id: :serial, force: :cascade do |t|
    t.string "reducer_id", null: false
    t.integer "project_id"
    t.integer "workflow_id"
    t.integer "subject_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_reductions_on_subject_id"
    t.index ["workflow_id", "subject_id", "reducer_id"], name: "index_reductions_on_workflow_id_and_subject_id_and_reducer_id", unique: true
    t.index ["workflow_id"], name: "index_reductions_on_workflow_id"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workflows", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.jsonb    "extractors_config"
    t.jsonb    "reducers_config"
    t.jsonb    "rules_config"
    t.jsonb    "webhooks"
  end

  add_foreign_key "actions", "subjects"
  add_foreign_key "actions", "workflows"
end
