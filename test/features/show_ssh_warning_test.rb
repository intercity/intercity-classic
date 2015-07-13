require "test_helper"

class ShowSshWarningTest < Capybara::Rails::TestCase
  test "It should show a warning when no SSH key is present" do
    app = applications(:intercity_beta)
    app.server.ssh_keys.destroy_all
    login_as users(:michiel)
    visit application_path(app.server, app)
    within ".server" do
      assert page.has_content?(/Before you can deploy/), "Page should have the SSH warning"
    end
  end

  test "It should now show a warning when an SSH key is present" do
    app = applications(:intercity_beta)
    login_as users(:michiel)
    visit application_path(app.server, app)
    within ".server" do
      refute page.has_content?(/Before you can deploy/), "Page should not have the SSH warning"
    end
  end
end
