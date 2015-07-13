require 'test_helper'

class ServerMaintainerTest < ActiveSupport::TestCase
  test "apply_changes removes key after running commands" do
    server = servers(:bootstrapped).dup
    server.generate_rsa_key!
    server.save

    command_aggregator = CommandAggregator.new
    maintainer = ServerMaintainer.new(server)
    CommandAggregator.stubs(:new).returns(command_aggregator)

    Timecop.freeze(Time.local(2013, 9, 27, 14, 27)) do
      apply_time = Time.now.to_i

      assert_difference "command_aggregator.count" do
        maintainer.apply_configuration
      end

      assert !File.exists?(Rails.root.join("keys", "#{server.id}_#{apply_time}_key")), "Expected key file to not exist"
    end

  end

  test "connect installs our key on the server" do
    server = servers(:new)
    server.send(:generate_passwords)

    command_aggregator = CommandAggregator.new
    CommandAggregator.stubs(:new).returns(command_aggregator)
    maintainer = ServerMaintainer.new(server)

    assert_difference "command_aggregator.count", 4 do
      maintainer.prepare("intercity", "intercity")
      maintainer.apply_configuration
    end
  end

  test "apply_backups runs the backup recipe on the server" do
    server = servers(:bootstrapped)
    server.generate_rsa_key!
    maintainer = ServerMaintainer.new(server)
    ChefExecution.any_instance.expects(:cook)
    maintainer.apply_backups
  end

  test "#remove_application runs the remove_applications recipe" do
    server = servers(:bootstrapped)
    server.generate_rsa_key!
    maintainer = ServerMaintainer.new(server)
    ChefExecution.any_instance.expects(:cook)
    maintainer.remove_application(server.applications.first)
  end
end
