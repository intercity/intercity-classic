class ChangeApplicationDomainNamesLength < ActiveRecord::Migration
  def change
    change_column :applications, :domain_names, :text
  end
end
