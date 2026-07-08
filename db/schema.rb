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

ActiveRecord::Schema[8.1].define(version: 2026_07_08_225252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cart_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_cart_products_on_product_id", unique: true
  end

  create_table "pgbus_batches", force: :cascade do |t|
    t.string "batch_id", null: false
    t.integer "completed_jobs", default: 0, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "description"
    t.integer "discarded_jobs", default: 0, null: false
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "finished_at"
    t.string "on_discard_class"
    t.string "on_finish_class"
    t.string "on_success_class"
    t.jsonb "properties", default: {}
    t.string "status", default: "pending", null: false
    t.integer "total_jobs", default: 0, null: false
    t.index ["batch_id"], name: "idx_pgbus_batches_batch_id", unique: true
    t.index ["status"], name: "idx_pgbus_batches_status"
  end

  create_table "pgbus_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "expires_at", null: false
    t.jsonb "payload", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "created_at"], name: "idx_pgbus_blocked_release_order"
  end

  create_table "pgbus_failed_events", force: :cascade do |t|
    t.text "backtrace"
    t.string "error_class"
    t.text "error_message"
    t.datetime "failed_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "headers"
    t.bigint "msg_id"
    t.jsonb "payload"
    t.string "queue_name", null: false
    t.integer "retry_count", default: 0
    t.index ["failed_at"], name: "idx_pgbus_failed_events_time"
    t.index ["queue_name", "msg_id"], name: "idx_pgbus_failed_events_queue_msg", unique: true
    t.index ["queue_name"], name: "idx_pgbus_failed_events_queue"
  end

  create_table "pgbus_pgmq_schema_versions", id: :serial, force: :cascade do |t|
    t.string "install_method", default: "embedded", null: false
    t.timestamptz "installed_at", default: -> { "now()" }, null: false
    t.string "version", null: false
  end

  create_table "pgbus_processed_events", force: :cascade do |t|
    t.string "event_id", null: false
    t.string "handler_class", null: false
    t.datetime "processed_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["event_id", "handler_class"], name: "idx_pgbus_processed_events_unique", unique: true
    t.index ["processed_at"], name: "idx_pgbus_processed_events_cleanup"
  end

  create_table "pgbus_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at"
    t.jsonb "metadata", default: {}
    t.integer "pid"
    t.datetime "updated_at", null: false
    t.index ["last_heartbeat_at"], name: "idx_pgbus_processes_heartbeat"
  end

  create_table "pgbus_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["run_at"], name: "idx_pgbus_recurring_executions_cleanup"
    t.index ["task_key", "run_at"], name: "idx_pgbus_recurring_executions_dedup", unique: true
  end

  create_table "pgbus_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "enabled", default: true, null: false
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "idx_pgbus_recurring_tasks_key", unique: true
  end

  create_table "pgbus_semaphores", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.integer "max_value", default: 1, null: false
    t.integer "value", default: 0, null: false
    t.index ["expires_at"], name: "idx_pgbus_semaphores_expired"
    t.index ["key"], name: "idx_pgbus_semaphores_key", unique: true
  end

  create_table "pgbus_stream_queues", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "idx_pgbus_stream_queues_queue_name", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "price"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "cart_products", "products"
end
