class AddBackupToAllApps < ActiveRecord::Migration
  def up
    Application.all.each do |app|
      unless app.backup.present?
        puts "[INFO] Creating backup strategy for app #{app.id}"
        Backup.create(application: app)
      end
    end
  end

  def down
    puts "[INFO] AddBackupToAllApps is not automaticly reversable"
  end
end
