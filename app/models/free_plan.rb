class FreePlan
  def id
    nil
  end

  def stripe_name
    "1 Server"
  end

  def stripe_amount
    0
  end

  def max_servers
    1
  end

  def next(staff = false)
    Plan.active(staff).lowest_first.first
  end

  def paid_plan?
    false
  end
end
