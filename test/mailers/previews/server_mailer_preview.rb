class ServerMailerPreview < ActionMailer::Preview
  def bootstrapped
    ServerMailer.bootstrapped(Server.last)
  end
end
