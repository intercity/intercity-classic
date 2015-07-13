class DeviseMailer < Devise::Mailer
  default from: Settings.intercity.from_email
end
