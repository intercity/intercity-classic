require "test_helper"

class FeatureFlipperTest < ActiveSupport::TestCase
  test "FeatureFlipper should act like a wrapper for Flipper" do
    flipper = FeatureFlipper.new
    testing_flip = flipper[:test]
    refute testing_flip.enabled?, "testing_flip should be disabled"
    testing_flip.enable
    assert testing_flip.enabled?, "testing_flip should be enabled"
  end

  test "FeatureFlipper should act on the Staff group" do
    flipper = FeatureFlipper.new
    testing_flip = flipper[:test]
    staff = User.new(staff: true)
    non_staff = User.new(staff: false)

    testing_flip.enable flipper.group(:staff)

    assert testing_flip.enabled?(staff), "Testing flip should be enabled for staff"
    refute testing_flip.enabled?(non_staff), "Testing flip should not be enabled non for staff"
  end
end
