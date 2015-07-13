require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "on_account" do
    @controller = AccountsController.new
    assert_equal "active", on_account
  end

  test "on_backups" do
    @controller = BackupsController.new
    @controller.action_name = "overview"
    assert_equal "active", on_backups
  end
end
