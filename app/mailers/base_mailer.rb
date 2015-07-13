class BaseMailer < ActionMailer::Base
  default from: Settings.intercity.from_email

  layout "email"
  before_action :attach_logo

  def attach_logo
    attachments.inline["logo.png"] = File.read(logo_path)
  end

  private

  def logo_path
    File.join(Rails.root, "app", "assets", "images", "logo-48-white.png")
  end
end
