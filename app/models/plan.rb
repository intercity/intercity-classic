class Plan < ActiveRecord::Base
  alias_attribute :name, :stripe_name

  scope :lowest_first, -> { order(:stripe_amount) }
  scope :highest_first, -> { order(stripe_amount: :desc) }

  default_scope { where(deleted_at: nil) }

  validates :stripe_id, uniqueness: { conditions: -> { where(active: true) } }

  def destroy
    update_attribute :deleted_at, Time.now
  end

  def name
    stripe_name
  end

  def next(include_staff = false)
    Plan.active(include_staff).find_by("stripe_amount > ?", stripe_amount)
  end

  def self.active(include_staff = false)
    scope = where(active: true)
    scope = scope.where(staff: false) unless include_staff
    scope
  end

  def paid_plan?
    true
  end
end
