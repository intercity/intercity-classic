require "test_helper"

class ServerMailerTest < ActionMailer::TestCase
  test "bootstrapped" do
    server = servers(:bootstrapped)
    mail = ServerMailer.bootstrapped(server.id)
    assert_equal "Intercity - Installation for server #{server.name} is finished", mail.subject
    assert_equal [server.owner.email], mail.to
  end
end
