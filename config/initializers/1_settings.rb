class Settings < Settingslogic
  source "#{Rails.root}/config/intercity.yml"
  namespace Rails.env
end
