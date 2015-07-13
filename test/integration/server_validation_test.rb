require 'test_helper'

class ServerValidationTest < ActiveSupport::TestCase

  if !ENV['CI']

    test "should fail with invalid host" do
      server = servers(:new_vagrant_server)
      server.address = 'invalid_address'
      server.save

      maintainer = ServerValidation.new(server, "test", "test")
      maintainer.stubs(:test_mode?).returns(false)

      assert maintainer.validate == false
      assert server.last_error == "Could not connect to your server on invalid_address:2222."
    end

    test "should fail when invalid password" do
      server = servers(:new_vagrant_server)

      maintainer = ServerValidation.new(server, "test", "lolcats")
      maintainer.stubs(:test_mode?).returns(false)

      assert maintainer.validate == false
      assert server.last_error == "SSH authentication failed."
    end

    test "should validate valid server" do
      server = servers(:new_vagrant_server)
      maintainer = ServerValidation.new(server, "vagrant", "vagrant")
      maintainer.stubs(:test_mode?).returns(false)
      assert maintainer.validate, "should be valid"
      assert server.last_error == nil
    end

    test "should fail when server not reachable (takes long time)" do
      return skip unless ENV['SLOW']

      puts "SSH Timeout test: This will take a while.. :( use rake "

      server = servers(:new_vagrant_server)
      server.address = "127.0.0.2"
      maintainer = ServerMaintainer.new(server)
      maintainer.stubs(:test_mode?).returns(false)

      maintainer.validate("test", "test") == false
      assert server.last_error == "Connect to SSH timed out, or server not reachable"
    end

    test "should fail when server cannot be provisioned due to no ubuntu" do
      server = servers(:new_vagrant_server)

      maintainer = ServerValidation.new(server, "vagrant", "vagrant")
      maintainer.stubs(:test_mode?).returns(false)

      maintainer.stubs(:check_version_command).returns("fake")
      assert maintainer.validate == false
      assert server.last_error == "Your server is not running Ubuntu 12.04 LTS or 14.04 LTS.", "Wrong error message"
    end

    test "should install and bootstrap a server" do
      return skip unless ENV['SLOW']
      server = servers(:new_vagrant_server)

      maintainer = ServerMaintainer.new(server)
      maintainer.stubs(:test_mode?).returns(false)

      logger = Logger.new(STDOUT)
      server.stubs(:logger).returns(logger)

      assert maintainer.prepare("intercity", "intercity"), "should be true"
      assert server.last_error == nil
    end

    test "should rescue apply_configuration when SSH key invalid" do
      return skip unless ENV['SLOW']
      owner = users(:michiel)
      server = Server.create!(address: "127.0.0.1",
                              name: "server with invalid key",
                              owner: owner, username: "root", ssh_port: 2222)
      server.generate_rsa_key!

      maintainer = ServerMaintainer.new(server)
      maintainer.stubs(:test_mode?).returns(false)

      logger_string = StringIO.new
      logger = Logger.new(logger_string)
      server.stubs(:logger).returns(logger)

      maintainer.apply_configuration

      assert logger_string.string.include?("Could not log in to server"),
             "Expected to include SSH key error"
    end

  end

end
