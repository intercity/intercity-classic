require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  setup do
    @plan = plans :basic
  end

  test 'stripe_name name alias' do
    assert_equal @plan.stripe_name, @plan.name, 'There should be name alias to stripe_name attribute'
  end

  test 'next returns next plan ordered by amount' do
    next_plan = @plan.dup
    next_plan.stripe_id = "10-servers"
    next_plan.stripe_amount = 10000
    next_plan.save!

    assert_equal next_plan, @plan.next
  end
end
