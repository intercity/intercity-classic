class SshKeyMaintainer
  def initialize(server)
    @server = server
    @key_file = nil
  end

  def install_ssh_key(username, password)
    return unless @server.rsa_key_encrypted.blank?

    @server.generate_rsa_key!

    ssh_key = SSHKey.new(@server.rsa_key_encrypted["private"], comment: "intercity")
    serverlogger.info "Copying SSH public key to server..."

    command = "mkdir -p .ssh && echo \"#{ssh_key.ssh_public_key}\" >> .ssh/authorized_keys"
    if Rails.env.test?
      command_aggregator.add(command)
    else
      SshExecution.new(@server).execute_with_password(command: command,
                                                      username: username,
                                                      password: password)
    end

    serverlogger.info "Done copying SSH public key."
  end

  def create_key_for_connection
    raise "RSA key not generated for this server" if @server.rsa_key_encrypted.blank?

    apply_stamp = Time.now.to_i
    @key_filename = "#{@server.id}_#{apply_stamp}_key"

    File.open(key_path, "w+", 0600) do |f|
      key_info = @server.rsa_key_encrypted
      f.write(key_info["private"])
    end

    @key_filename
  end

  def key
    create_key_for_connection if @key_filename.nil?
    key_path
  end

  def delete_ssh_key_for_connection
    File.delete(key) unless @key_filename.nil?
  end

  private

  def key_path
    FileUtils.mkdir_p("keys") unless File.directory?("keys")
    Rails.root.join("keys", @key_filename)
  end

  def command_aggregator
    @command_aggregator ||= CommandAggregator.new
  end

  def serverlogger
    ServerLog.new(@server).logger
  end
end
