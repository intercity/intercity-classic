require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "All fixtures are valid" do
    User.all.each do |user|
      assert user.valid?, "User #{user.email} fixture should be valid"
    end
  end

  test "applications_with_backups" do
    app = applications(:chef_builder_app1)
    apps = users(:michiel).applications_with_backups
    assert_includes apps, app
  end
end
