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

ActiveRecord::Schema.define(version: 20170111161040) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "classifications", force: :cascade do |t|
    t.jsonb    "annotations",              array: true
    t.integer  "project_id"
    t.integer  "workflow_id"
    t.integer  "user_id"
    t.datetime "inserted_at", null: false
    t.datetime "updated_at",  null: false
  end

  create_table "extracts", force: :cascade do |t|
    t.integer  "classification_id"
    t.datetime "classification_at"
    t.integer  "extractor_id"
    t.integer  "project_id"
    t.integer  "workflow_id"
    t.integer  "user_id"
    t.integer  "subject_id"
    t.jsonb    "data"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["classification_id", "extractor_id"], name: "index_extracts_on_classification_id_and_extractor_id", unique: true, using: :btree
    t.index ["subject_id"], name: "index_extracts_on_subject_id", using: :btree
    t.index ["user_id"], name: "index_extracts_on_user_id", using: :btree
    t.index ["workflow_id"], name: "index_extracts_on_workflow_id", using: :btree
  end

  create_table "reductions", force: :cascade do |t|
    t.integer  "reducer_id"
    t.integer  "project_id"
    t.integer  "workflow_id"
    t.integer  "subject_id"
    t.jsonb    "data"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["subject_id"], name: "index_reductions_on_subject_id", using: :btree
    t.index ["workflow_id", "subject_id", "reducer_id"], name: "index_reductions_on_workflow_id_and_subject_id_and_reducer_id", unique: true, using: :btree
    t.index ["workflow_id"], name: "index_reductions_on_workflow_id", using: :btree
  end

  create_table "subjects", force: :cascade do |t|
    t.jsonb    "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workflows", force: :cascade do |t|
    t.integer  "project_id"
    t.jsonb    "rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
