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

ActiveRecord::Schema.define(version: 20171122160848) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

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
    t.integer "user_id"
    t.integer "rule_id"
    t.index ["subject_id"], name: "index_actions_on_subject_id"
    t.index ["workflow_id"], name: "index_actions_on_workflow_id"
  end

  create_table "classifications", id: :integer, default: nil, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "workflow_id", null: false
    t.integer "user_id"
    t.integer "subject_id", null: false
    t.string "workflow_version", null: false
    t.jsonb "annotations", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "received_at", default: -> { "now()" }, null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.text "token", null: false
    t.string "refresh"
    t.datetime "expires_at", null: false
    t.integer "project_ids", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_credentials_on_token", unique: true
  end

  create_table "data_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "user_id"
    t.bigint "workflow_id", null: false
    t.string "subgroup"
    t.integer "requested_data"
    t.string "url"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false, null: false
    t.index ["user_id", "workflow_id", "subgroup", "requested_data"], name: "look_up_existing", unique: true
    t.index ["workflow_id"], name: "index_data_requests_on_workflow_id"
  end

  create_table "extractors", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.string "key", null: false
    t.string "type", null: false
    t.jsonb "config", default: {}, null: false
    t.string "minimum_workflow_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_id", "key"], name: "index_extractors_on_workflow_id_and_key", unique: true
    t.index ["workflow_id"], name: "index_extractors_on_workflow_id"
  end

  create_table "extracts", id: :serial, force: :cascade do |t|
    t.integer "classification_id", null: false
    t.datetime "classification_at", null: false
    t.string "extractor_key", null: false
    t.integer "workflow_id", null: false
    t.integer "user_id"
    t.integer "subject_id", null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classification_id", "extractor_key"], name: "index_extracts_on_classification_id_and_extractor_key", unique: true
    t.index ["subject_id"], name: "index_extracts_on_subject_id"
    t.index ["user_id"], name: "index_extracts_on_user_id"
    t.index ["workflow_id"], name: "index_extracts_on_workflow_id"
  end

  create_table "reducers", force: :cascade do |t|
    t.bigint "workflow_id"
    t.string "key", null: false
    t.string "type", null: false
    t.string "grouping"
    t.jsonb "config", default: {}, null: false
    t.jsonb "filters", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "topic", default: 0
    t.index ["workflow_id", "key"], name: "index_reducers_on_workflow_id_and_key", unique: true
    t.index ["workflow_id"], name: "index_reducers_on_workflow_id"
  end

  create_table "reductions", id: :serial, force: :cascade do |t|
    t.string "reducer_key", null: false
    t.integer "workflow_id", null: false
    t.integer "subject_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subgroup", default: "_default", null: false
    t.integer "user_id"
    t.index ["subject_id"], name: "index_reductions_on_subject_id"
    t.index ["workflow_id", "subgroup"], name: "index_reductions_workflow_id_and_subgroup"
    t.index ["workflow_id", "subject_id", "reducer_key", "subgroup"], name: "index_reductions_subject_covering"
    t.index ["workflow_id", "subject_id"], name: "index_reductions_on_workflow_id_and_subject_id"
    t.index ["workflow_id", "user_id", "reducer_key", "subgroup"], name: "index_reductions_user_covering"
    t.index ["workflow_id"], name: "index_reductions_on_workflow_id"
  end

  create_table "rule_effects", force: :cascade do |t|
    t.bigint "rule_id", null: false
    t.integer "action", null: false
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rule_id"], name: "index_rule_effects_on_rule_id"
  end

  create_table "rules", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.jsonb "condition", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "topic", default: 0
    t.index ["workflow_id"], name: "index_rules_on_workflow_id"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workflows", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "webhooks_config", default: [], null: false
    t.boolean "public_extracts", default: false, null: false
    t.boolean "public_reductions", default: false, null: false
  end

  add_foreign_key "actions", "subjects"
  add_foreign_key "actions", "workflows"
  add_foreign_key "classifications", "subjects"
  add_foreign_key "classifications", "workflows"
  add_foreign_key "data_requests", "workflows"
  add_foreign_key "extractors", "workflows"
  add_foreign_key "extracts", "subjects"
  add_foreign_key "extracts", "workflows"
  add_foreign_key "reducers", "workflows"
  add_foreign_key "reductions", "subjects"
  add_foreign_key "reductions", "workflows"
  add_foreign_key "rule_effects", "rules"
  add_foreign_key "rules", "workflows"
end
