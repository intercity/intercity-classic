class Settings < Settingslogic
  source "#{Rails.root}/config/intercity.yml"
  namespace Rails.env
end

#
# Backup
#
Settings['backup'] ||= Settingslogic.new({})
Settings.backup['keep_time']  ||= 0
Settings.backup['path']         = File.expand_path(Settings.backup['path'] || "tmp/backups/", Rails.root)
Settings.backup['archive_permissions']          ||= 0600
