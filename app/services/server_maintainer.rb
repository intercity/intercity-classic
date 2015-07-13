class ServerMaintainer
  include ServersHelper

  def initialize(server)
    @server = server
    @server.last_error = nil
    move_old_log_file
  end

  def prepare(username, password)
    @server.username = username
    if @server.metal? && password
      unless ServerValidation.new(@server, username, password).validate
        return false
      end
      if @server.reload.server_version == "12.04"
        SshExecution.new(@server.reload).
          execute_with_password(command: "sudo locale-gen en_US.UTF-8; sudo dpkg-reconfigure locales",
                                username: username, password: password)
      end
      SshKeyMaintainer.new(@server).install_ssh_key(username, password)
    end
    chef_execution.prepare(password)
    true
  end

  def apply_ssh_keys(password = nil)
    builder = ChefConfigurationBuilder.new(@server).
              add(recipe: "ssh_deploy_keys").
              add(ssh_deploy_keys: @server.deploy_keys)

    chef_execution.cook(builder.config, builder.runlist, password)
  end

  def apply_backups(password = nil)
    builder = ChefConfigurationBuilder.new(@server).add(role: "backup")
    @server.applications.each do |app|
      builder.backup_for app
    end

    chef_execution.cook(builder.config, builder.runlist, password)
  end

  def remove_application(app)
    builder = ChefConfigurationBuilder.new(@server).add(role: "remove_applications")
    builder.remove_app app
    chef_execution.cook(builder.config, builder.runlist, nil)
  end

  def cleanup
    chef_execution.clean
  end

  def apply_configuration(password = nil)
    builder = ChefConfigurationBuilder.new(@server).add(role: "base").
              add(ssh_deploy_keys: @server.deploy_keys).
              add(unattended_upgrades: @server.unattended_upgrades).
              rails(applications_root: @server.applications_root).
              nginxize(client_max_body_size: "20m")

    case @server.db_type
    when "mysql"
      builder.mysqlize @server.mysql_passwords_encrypted
    when "postgres"
      builder.postgresize @server.postgres_passwords_encrypted
    end

    if @server.unicorn?
      builder.add role: "rails"
    elsif @server.passenger?
      builder.add role: "rails_passenger"
    end

    @server.applications.each do |app|
      builder.application app
    end

    chef_execution.cook(builder.config, builder.runlist, password)
    true
  end

  def force_backup(application)
    SshExecution.new(@server).
      execute(command: "sudo su - deploy -c \"cd /home/deploy/Backup && backup perform "\
              "--trigger #{application.name}\"",
              channeled: true)
  end

  def ssh_active?
    begin
      result = SshExecution.new(@server).execute(command: "pwd")
    rescue Net::SSH::AuthenticationFailed, Timeout::Error, Errno::ECONNREFUSED, Net::SSH::Disconnect
      result = false
    end
    result
  end

  private

  def move_old_log_file
    ServerLog.new(@server).move_old
  end

  def chef_execution
    @executioner ||= ChefExecution.new(@server)
  end
end
