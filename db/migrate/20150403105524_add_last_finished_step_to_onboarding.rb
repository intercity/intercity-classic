class AddLastFinishedStepToOnboarding < ActiveRecord::Migration
  def change
    add_column :onboardings, :last_finished_step, :string
  end
end
