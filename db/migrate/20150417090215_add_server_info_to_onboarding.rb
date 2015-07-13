class AddServerInfoToOnboarding < ActiveRecord::Migration
  def change
    add_column :onboardings, :ip, :string
    add_column :onboardings, :port, :integer
    add_column :onboardings, :username, :string
  end
end
