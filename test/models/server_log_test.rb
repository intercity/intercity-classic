require "test_helper"

class ServerLogTest < ActiveSupport::TestCase
  test "Log should return the correct server log path" do
    server = Server.new(id: 12)
    ServerLog.any_instance.stubs(:test_mode?).returns(false)
    expected_log = Rails.root.join("log", "servers", "12.log")
    assert_equal expected_log, ServerLog.new(server).file
  end

  test "Logger should return an instance of Logger" do
    server = Server.new(id: 12)
    assert_kind_of Logger, ServerLog.new(server).logger
  end

  test "Latest should return the latest N lines from the log file" do
    server = Server.new(id: 12)
    logger = ServerLog.new(server)
    logger.stubs(:file).returns(Rails.root.join("test", "fixtures", "files", "testlog.log"))
    log = logger.latest(10)
    assert_equal 10, log.lines.count
  end
end
