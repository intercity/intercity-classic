require 'test_helper'

class SubscriptionsHelperTest < ActionView::TestCase
  include SubscriptionsHelper

  test 'expiration_month_options' do
    assert_not_nil expiration_month_options
  end

  test 'expiration_year_options' do
    assert_not_nil expiration_year_options
  end

  test "format_monthly_amount" do
    free_amount = format_monthly_amount(0)
    assert_equal "Free!", free_amount

    ten_a_month = format_monthly_amount(1000)
    assert_equal "$10/month", ten_a_month
  end
end
