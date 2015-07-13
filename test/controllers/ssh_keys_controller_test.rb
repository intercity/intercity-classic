require "test_helper"

class SshKeysControllerTest < ActionController::TestCase
  def setup
    sign_in users(:michiel)
    @server = servers(:bootstrapped)
  end

  test "should post create" do
    assert_difference "SshKey.count" do
      post :create, server_id: @server.id, ssh_key: { name: "MyKey", key: "foobar123456789" }
    end

    assert_response :redirect
  end

  test "should delete destroy" do
    assert_difference "SshKey.count", -1 do
      delete :destroy, server_id: @server.id, id: ssh_keys(:sshkey_one)
    end

    assert_response :redirect
  end
end
