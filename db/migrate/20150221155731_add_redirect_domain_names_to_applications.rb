class AddRedirectDomainNamesToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :redirect_domain_names, :text
  end
end
