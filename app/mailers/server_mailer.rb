class ServerMailer < BaseMailer
  def bootstrapped(server_id)
    @server = Server.find(server_id)
    @user = @server.owner

    mail to: @user.email, subject: "Intercity -  Installation for server #{@server.name} is finished"
  end
end
