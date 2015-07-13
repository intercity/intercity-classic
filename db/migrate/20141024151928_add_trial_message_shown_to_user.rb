class AddTrialMessageShownToUser < ActiveRecord::Migration
  def change
    add_column :users, :trial_message_shown, :boolean, default: false
  end
end
