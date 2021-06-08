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

ActiveRecord::Schema.define(version: 2021_06_08_214455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "command_proposal_comments", id: :serial, force: :cascade do |t|
    t.integer "iteration_id"
    t.integer "line_number"
    t.integer "author_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_command_proposal_comments_on_author_id"
    t.index ["iteration_id"], name: "index_command_proposal_comments_on_iteration_id"
  end

  create_table "command_proposal_iterations", id: :serial, force: :cascade do |t|
    t.integer "task_id"
    t.text "args"
    t.text "code"
    t.text "result"
    t.integer "status"
    t.integer "requester_id"
    t.integer "approver_id"
    t.datetime "approved_at"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "stopped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_command_proposal_iterations_on_approver_id"
    t.index ["requester_id"], name: "index_command_proposal_iterations_on_requester_id"
    t.index ["task_id"], name: "index_command_proposal_iterations_on_task_id"
  end

  create_table "command_proposal_tasks", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "description"
    t.integer "session_type"
    t.datetime "last_executed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
