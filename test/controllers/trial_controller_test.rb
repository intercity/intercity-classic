require 'test_helper'

class TrialControllerTest < ActionController::TestCase
  test "#availabilty should tell if a username is available" do
    get :availability, full_name: "John", email: "available@example.com",
                                 password: "12345678"
    assert_equal Hash.new, JSON.parse(response.body)["errors"]

    existing_user = users(:michiel)
    get :availability, full_name: "John", email: existing_user.email,
                                 password: "12345678"
    refute_equal Hash.new, JSON.parse(response.body)["errors"]
  end
end
