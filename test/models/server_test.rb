require 'test_helper'

class ServerTest < ActiveSupport::TestCase
  should have_one :onboarding

  should validate_presence_of :name
  should validate_presence_of :address
  should validate_presence_of :ssh_port

  test "All fixtures are valid" do
    Server.all.each do |server|
      assert server.valid?, "Server #{server.name} fixture should be valid"
    end
  end

  test "do not generate mysql/postgres passwords when already set" do
    server = servers(:bootstrapped)
    server.mysql_passwords_encrypted = { server_debian_password: 'test' }
    server.postgres_passwords_encrypted = {password: {postgres: 'pest'}}

    server.save!
    server.reload

    assert_equal 'test', server.mysql_passwords_encrypted['server_debian_password']
    assert_equal 'pest', server.postgres_passwords_encrypted['password']['postgres']
  end

  test "generate_rsa_key! generates ssh key for server" do
    server = servers(:bootstrapped)
    server.generate_rsa_key!

    rsa_key = server.rsa_key_encrypted

    assert rsa_key.has_key?('private')
  end

  test "pending_changes? if server updated_at is bigger than latest applied_at" do
    server = servers(:bootstrapped)
    server.applied_at = 1.day.ago

    server.touch

    assert server.pending_changes?
  end

  test 'get unique deploy users from all apps' do
    server = Server.new

    %w{ted igor ted}.each do |user|
      server.applications << Application.new(deploy_user: user)
    end

    assert_equal ['deploy', 'ted', 'igor'], server.deploy_users, 'Wrong list of deploy users'
  end

  test 'should return a list of public ssh keys' do
    server = Server.new
    server.ssh_keys.new(name: 'Michiel', key: 'ssh-rsa 00FFA')
    server.ssh_keys.new(name: 'Bob', key: 'ssh-rsa 00ABC')
    assert_equal ['ssh-rsa 00FFA', 'ssh-rsa 00ABC'], server.deploy_keys
  end

  test 'should return an empty list if there no ssh keys for server' do
    server = Server.new
    assert_equal [], server.deploy_keys, 'Must be empty'
  end
end
