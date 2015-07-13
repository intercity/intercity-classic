require "test_helper"

class SignupFlowTest < ActionDispatch::IntegrationTest
  test "Sign up and start onboarding" do
    https!
    post_via_redirect "/trial/signup", full_name: "Michiel Sikkes", email: "michiel@intercityup.com", password: "12345678"
    assert_equal "/", path
    assert response.body.include?("Let's get your apps hosted")
  end
end
