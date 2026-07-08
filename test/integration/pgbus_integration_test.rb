require "test_helper"

# End-to-end coverage for the pgbus setup: adapter → PGMQ → worker-style
# execution, the mounted dashboard, and event-bus capture in tests.
#
# The PGMQ round-trip runs against the real pgmq schema in the test database.
# schema.rb cannot carry that schema, but Pgbus.client installs the embedded
# SQL on first access. pgbus writes through its own PG connections (not
# ActiveRecord's), so transactional tests are disabled here — anything pgbus
# writes is committed immediately and must be cleaned up in teardown.
class PgbusIntegrationTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  class ProbeJob < ApplicationJob
    self.queue_adapter = :pgbus
    queue_as :default

    class_attribute :performed_with

    def perform(arg)
      self.class.performed_with = arg
    end
  end

  teardown do
    Pgbus::Testing.disabled! { Pgbus.client.purge_queue("default") }
  end

  test "job enqueued through the pgbus adapter lands in PGMQ and executes like a worker would" do
    Pgbus::Testing.disabled! do
      ProbeJob.performed_with = nil

      ProbeJob.perform_later("round-trip")

      message = Pgbus.client.read_message("default")
      assert message, "expected the job to be readable from the pgbus default queue"

      payload = JSON.parse(message.message)
      assert_equal ProbeJob.name, payload["job_class"]
      assert_equal [ "round-trip" ], payload["arguments"]

      result = Pgbus::ActiveJob::Executor.new.execute(message, "default")

      assert_equal :success, result
      assert_equal "round-trip", ProbeJob.performed_with
      assert_nil Pgbus.client.read_message("default"), "queue should be empty after execution"
    end
  end

  test "dashboard is mounted and renders" do
    get "/pgbus"
    follow_redirect! while response.redirect?

    assert_response :success
    assert_includes response.body, "Pgbus"
  end

  test "published events are captured in fake mode" do
    assert_pgbus_published(count: 1, routing_key: "plexy.test.ping") do
      Pgbus.publish("plexy.test.ping", { ok: true })
    end

    event = pgbus_published_events(routing_key: "plexy.test.ping").sole
    assert_equal({ "ok" => true }, event.payload)
  end
end
