class AddDigitaloceanApiKeyToOnboarding < ActiveRecord::Migration
  def change
    add_column :onboardings, :digitalocean_api_key, :string
  end
end
