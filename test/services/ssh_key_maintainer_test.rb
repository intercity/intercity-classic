require "test_helper"

class SshKeyMaintainerTest < ActiveSupport::TestCase
  test "install_ssh_key should add one command" do
    server = servers(:new)
    aggregator = CommandAggregator.new
    ssh_key_maintainer = SshKeyMaintainer.new(server)
    ssh_key_maintainer.stubs(:command_aggregator).returns(aggregator)
    assert_difference "aggregator.count" do
      ssh_key_maintainer.install_ssh_key("test", "test")
    end
  end

  test "create_ssh_key_for_connection creates a ssh_key" do
    server = servers(:new)
    server.generate_rsa_key!

    ssh_key_maintainer = SshKeyMaintainer.new(server)
    ssh_file = ssh_key_maintainer.create_key_for_connection
    assert File.exist?("keys/#{ssh_file}")
    File.delete("keys/#{ssh_file}")
  end
end
