module SubscriptionsHelper
  def expiration_month_options
    options_for_select(1..12, selected: Date.today.month)
  end

  def expiration_year_options
    options_for_select(Date.today.year..(Date.today.year + 10), selected: Date.today.year)
  end

  def current_user_subscribed_to?(plan)
    if plan.is_a?(FreePlan) && current_user.plan.is_a?(FreePlan)
      true
    else
      current_user.subscribed? && current_user.active_subscription.plan == plan
    end
  end

  def format_monthly_amount(amount)
    if amount == 0
      "Free!"
    else
      "$#{amount / 100}/month"
    end
  end
end
