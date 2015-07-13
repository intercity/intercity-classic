class Onboarding::CustomServersController < Onboarding::BaseController
  def new
    @onboarding = fetch_onboarding
    @ssh_key = SSHKey.new(@onboarding.rsa_key_encrypted["private"],
                          comment: "Intercity")
  end

  def test_ip
    onboarding = fetch_onboarding
    @port = params[:port]
    begin
      Timeout.timeout(5) do
        sock = Socket.new(:INET, :STREAM)
        raw = Socket.sockaddr_in(@port, params[:ip])
        @connected = sock.connect(raw)
        onboarding.update(ip: params[:ip], port: params[:port]) if @connected
      end
    rescue Errno::ECONNREFUSED, SocketError, Errno::EAFNOSUPPORT, Errno::ETIMEDOUT,
           Errno::EADDRNOTAVAIL, Timeout::Error
      @connected = false
    end
    respond_to :js
  end

  def test_ssh
    onboarding = fetch_onboarding
    server = Server.new(rsa_key_encrypted: onboarding.rsa_key_encrypted,
                        address: params[:ip], ssh_port: params[:port], id: onboarding.id,
                        username: params[:user])
    begin
      output = SshExecution.new(server).execute(command: "sudo ls")
      if output =~ /sudo/
        @connected = false
      else
        @connected = true
        onboarding.update(username: params[:user], last_finished_step: "check_custom_server")
      end
    rescue Net::SSH::AuthenticationFailed
      @connected = false
    end
    respond_to :js
  end

  def show
    @onboarding = fetch_onboarding
  end
end
