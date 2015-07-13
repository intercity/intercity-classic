require 'test_helper'

class SshKeyTest < ActiveSupport::TestCase
  should validate_presence_of :server_id
  should validate_presence_of :name
  should validate_presence_of :key

  test "All fixtures are valid" do
    SshKey.all.each do |ssh_key|
      assert ssh_key.valid?, "ssh_key #{ssh_key.name} fixture should be valid"
    end
  end
end
