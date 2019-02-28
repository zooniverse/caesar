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

ActiveRecord::Schema.define(version: 2019_02_28_170119) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

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
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false, null: false
    t.integer "records_count"
    t.integer "records_exported"
    t.integer "exportable_id"
    t.string "exportable_type"
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
    t.integer "project_id"
    t.index ["classification_id", "extractor_key"], name: "index_extracts_on_classification_id_and_extractor_key", unique: true
    t.index ["project_id"], name: "index_extracts_on_project_id"
    t.index ["subject_id"], name: "index_extracts_on_subject_id"
    t.index ["user_id"], name: "index_extracts_on_user_id"
    t.index ["workflow_id", "updated_at"], name: "extracts_updated_by_workflow"
    t.index ["workflow_id"], name: "index_extracts_on_workflow_id"
  end

  create_table "extracts_subject_reductions", id: false, force: :cascade do |t|
    t.bigint "extract_id", null: false
    t.bigint "subject_reduction_id", null: false
    t.index ["extract_id", "subject_reduction_id"], name: "cur_covering_1"
    t.index ["subject_reduction_id", "extract_id"], name: "cur_covering_2"
  end

  create_table "extracts_user_reductions", id: false, force: :cascade do |t|
    t.bigint "extract_id", null: false
    t.bigint "user_reduction_id", null: false
    t.index ["extract_id", "user_reduction_id"], name: "eur_covering_1"
    t.index ["user_reduction_id", "extract_id"], name: "eur_covering_2"
  end

  create_table "projects", force: :cascade do |t|
    t.jsonb "reducers_config"
    t.jsonb "rules_config"
    t.integer "rules_applied", default: 0, null: false
    t.boolean "public_reductions", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.integer "subject_reductions_count"
    t.integer "user_reductions_count"
    t.integer "reducers_count"
    t.integer "status", default: 1, null: false
  end

  create_table "reducers", force: :cascade do |t|
    t.bigint "workflow_id"
    t.string "key", null: false
    t.string "type", null: false
    t.jsonb "config", default: {}, null: false
    t.jsonb "filters", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "topic", default: 0, null: false
    t.integer "reduction_mode", default: 0, null: false
    t.jsonb "grouping", default: {}, null: false
    t.integer "reducible_id"
    t.string "reducible_type"
    t.index ["workflow_id", "key"], name: "index_reducers_on_workflow_id_and_key", unique: true
    t.index ["workflow_id"], name: "index_reducers_on_workflow_id"
  end

  create_table "subject_actions", id: :serial, force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.integer "subject_id", null: false
    t.string "effect_type", null: false
    t.jsonb "config", default: {}, null: false
    t.integer "status", default: 0, null: false
    t.datetime "attempted_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rule_id"
    t.index ["subject_id"], name: "index_subject_actions_on_subject_id"
    t.index ["workflow_id", "updated_at"], name: "subject_actions_updated_by_workflow"
    t.index ["workflow_id"], name: "index_subject_actions_on_workflow_id"
  end

  create_table "subject_reductions", id: :serial, force: :cascade do |t|
    t.string "reducer_key", null: false
    t.integer "workflow_id", null: false
    t.integer "subject_id", null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subgroup", default: "_default", null: false
    t.integer "lock_version", default: 0, null: false
    t.jsonb "store"
    t.boolean "expired", default: false
    t.integer "reducible_id"
    t.string "reducible_type"
    t.index ["reducible_id", "reducible_type", "updated_at"], name: "subject_reductions_recency"
    t.index ["reducible_type", "reducible_id", "subject_id", "reducer_key", "subgroup"], name: "index_subject_reductions_covering", unique: true
    t.index ["subject_id"], name: "index_subject_reductions_on_subject_id"
    t.index ["workflow_id", "subgroup"], name: "index_reductions_workflow_id_and_subgroup"
    t.index ["workflow_id", "subject_id"], name: "index_subject_reductions_on_workflow_id_and_subject_id"
    t.index ["workflow_id"], name: "index_subject_reductions_on_workflow_id"
  end

  create_table "subject_rule_effects", force: :cascade do |t|
    t.bigint "subject_rule_id", null: false
    t.integer "action", null: false
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_rule_id"], name: "index_subject_rule_effects_on_subject_rule_id"
  end

  create_table "subject_rules", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.jsonb "condition", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "topic", default: 0, null: false
    t.integer "row_order"
    t.index ["workflow_id"], name: "index_subject_rules_on_workflow_id"
  end

  create_table "subjects", id: :serial, force: :cascade do |t|
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_actions", force: :cascade do |t|
    t.bigint "workflow_id", null: false
    t.integer "user_id", null: false
    t.string "effect_type", null: false
    t.jsonb "config", default: {}, null: false
    t.integer "status", default: 0, null: false
    t.datetime "attempted_at"
    t.datetime "completed_at"
    t.integer "rule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_subject_actions_on_user_id"
    t.index ["workflow_id", "updated_at"], name: "user_actions_updated_by_workflow"
    t.index ["workflow_id"], name: "index_user_actions_on_workflow_id"
  end

  create_table "user_reductions", force: :cascade do |t|
    t.string "reducer_key", null: false
    t.integer "workflow_id", null: false
    t.integer "user_id", null: false
    t.jsonb "data"
    t.string "subgroup", default: "_default", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.jsonb "store"
    t.boolean "expired", default: false
    t.integer "reducible_id"
    t.string "reducible_type"
    t.index ["reducible_id", "reducible_type", "updated_at"], name: "user_reductions_recency"
    t.index ["user_id"], name: "index_user_reductions_on_user_id"
    t.index ["workflow_id", "user_id", "reducer_key", "subgroup"], name: "index_user_reductions_covering"
    t.index ["workflow_id", "user_id"], name: "index_user_reductions_on_workflow_id_and_user_id"
    t.index ["workflow_id"], name: "index_user_reductions_on_workflow_id"
  end

  create_table "user_rule_effects", force: :cascade do |t|
    t.integer "action"
    t.jsonb "config", default: {}, null: false
    t.bigint "user_rule_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_rule_id"], name: "index_user_rule_effects_on_user_rule_id"
  end

  create_table "user_rules", force: :cascade do |t|
    t.jsonb "condition"
    t.bigint "workflow_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "row_order"
    t.index ["workflow_id"], name: "index_user_rules_on_workflow_id"
  end

  create_table "workflows", id: :serial, force: :cascade do |t|
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public_extracts", default: false, null: false
    t.boolean "public_reductions", default: false, null: false
    t.integer "rules_applied", default: 0, null: false
    t.string "name"
    t.string "project_name"
    t.integer "status", default: 1, null: false
    t.integer "extracts_count"
    t.integer "subject_reductions_count"
    t.integer "user_reductions_count"
    t.integer "subject_actions_count"
    t.integer "user_actions_count"
    t.integer "extractors_count"
    t.integer "reducers_count"
    t.integer "subject_rules_count"
    t.integer "user_rules_count"
  end

  add_foreign_key "classifications", "subjects"
  add_foreign_key "classifications", "workflows"
  add_foreign_key "extractors", "workflows"
  add_foreign_key "extracts", "subjects"
  add_foreign_key "extracts", "workflows"
  add_foreign_key "extracts_subject_reductions", "extracts", on_delete: :cascade
  add_foreign_key "extracts_subject_reductions", "subject_reductions", on_delete: :cascade
  add_foreign_key "extracts_user_reductions", "extracts", on_delete: :cascade
  add_foreign_key "extracts_user_reductions", "user_reductions", on_delete: :cascade
  add_foreign_key "subject_actions", "subjects"
  add_foreign_key "subject_actions", "workflows"
  add_foreign_key "subject_reductions", "subjects"
  add_foreign_key "subject_rule_effects", "subject_rules"
  add_foreign_key "subject_rules", "workflows"
  add_foreign_key "user_actions", "workflows"
  add_foreign_key "user_rule_effects", "user_rules"
  add_foreign_key "user_rules", "workflows"
end
