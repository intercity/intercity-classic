require "test_helper"

class EnvVarTest < ActiveSupport::TestCase
  should belong_to :application

  should validate_presence_of :key
  should validate_presence_of :value

  should allow_value("super_var").for(:key)
  should_not allow_value("super var").for(:key)

  should allow_value("super_var").for(:value)
  should allow_value("super:/var").for(:value)
  should allow_value("john@example.com").for(:value)
  should allow_value("hello-john").for(:value)
  should allow_value("postgis://A99m:Z8DQLTKKA+g==@loca/Mkten?pool=5").for(:value)
  should_not allow_value("super var").for(:value)
end
