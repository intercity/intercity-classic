require "test_helper"

class RemoveApplicationTest < Capybara::Rails::TestCase
  test "Success path" do
    app = applications(:intercity_beta)
    login_as users(:michiel)
    visit application_path(app.server, app)
    within ".application_navigation" do
      click_link "Settings"
    end
    assert_equal edit_application_path(app.server, app), current_path
    click_link "Remove #{app.name}"
    click_link "I understand, remove #{app.name}"
    assert app.reload.deleting?, "App should be marked as deleting"
    assert_equal applications_path(app.server), current_path
  end
end
