# Chef configuration builder
#
# ==== Examples
#
#   ChefConfigurationBuilder.new
#     .add(role: 'mysql')
#     .add(role: 'rails')
#     .add(sudoer: 'intercity')
#     .build
#
class ChefConfigurationBuilder
  def initialize(server)
    @roles = []
    @recipes = []
    @sudoers = []
    @nginx = {}
    @mysql = {}
    @rails = {}
    @postgresql = {}
    @ssh_deploy_keys = []
    @deploy_users = []
    @applications = {}
    @remove_applications = []
    @backups = {}
    @server = server
    @unattended_upgrades = nil
    add_sudoers
    add_deploy_users
  end

  def add(*config)
    var_name = "@#{config[0].keys.first.to_s.pluralize}"
    value = config[0].values.first
    if instance_variable_defined? var_name
      var = instance_variable_get var_name
      if instance_variable_defined?(var_name) && value.is_a?(Array)
        instance_variable_set(var_name, var + value)
      elsif var.is_a?(Array)
        var << value
      else
        instance_variable_set(var_name, value)
      end
    end
    self
  end

  def nginxize(*attributes)
    configure @nginx, attributes
    self
  end

  def mysqlize(*attributes)
    @roles << "mysql"
    configure @mysql, attributes
    self
  end

  def postgresize(*attributes)
    @roles << "postgresql"
    configure @postgresql, attributes
    self
  end

  def rails(*attributes)
    configure @rails, attributes
    self
  end

  def application(app)
    raise ArgumentError unless app.is_a? Application
    @applications[app.name] = {
      domain_names: app.domain_names.split,
      redirect_domain_names: app.redirect_domain_names.try(:split),
      env_vars: app.formatted_env_vars,
      enable_ssl: app.enable_ssl,
      ruby_version: app.ruby_version,
      packages: %w(nodejs imagemagick),
      rails_env: app.rails_environment,
      deploy_user: app.deploy_user,
      client_max_body_size: app.client_max_body_size.present? ? "#{app.client_max_body_size}m" : nil
    }

    application_database_to_connect_to = app

    if app.use_database_from_other_application?
      application_database_to_connect_to = app.connect_to_database_from_application
    end

    @applications[app.name][:database_info] = {
      adapter: db_adapter_name(application_database_to_connect_to.server.db_type),
      host: application_database_to_connect_to.database_host,
      username: application_database_to_connect_to.database_user_encrypted,
      password: application_database_to_connect_to.database_password_encrypted,
      database: application_database_to_connect_to.database_name
    }

    if app.enable_ssl?
      @applications[app.name][:ssl_info] = {
        key: app.ssl_key,
        crt: app.ssl_cert
      }
    end

    self
  end

  def backup_for(app)
    raise ArgumentError unless app.is_a? Application
    backup = app.backup
    @backups[app.name] = {
      enabled: backup.enabled?,
      storage_type: backup.storage_type,
      s3_access_key: backup.s3_access_key,
      s3_secret_access_key: backup.s3_secret_access_key,
      s3_bucket: backup.s3_bucket,
      s3_region: backup.s3_region,
      database_type: @server.db_type,
      database_username: app.database_user_encrypted,
      database_password: app.database_password_encrypted,
      database_host: app.database_host,
      database_name: app.database_name
    }
    self
  end

  def remove_app(app)
    raise ArgumentError unless app.is_a? Application
    @remove_applications << app.name
    self
  end

  # Builds a config hash for chef node definition
  def config
    config = {
      authorization: {
        sudo: {
          users: @sudoers
        }
      }
    }
    %w(nginx mysql postgresql ssh_deploy_keys deploy_users rails).each do |sym|
      v = instance_variable_get "@#{sym}"
      config.merge!(sym.to_sym => v) unless v.empty?
    end
    config.merge!(rbenv: { group_users: @deploy_users }) unless @deploy_users.empty?
    config.merge!(backups: @backups) unless @backups.empty?
    config.merge!(active_applications: @applications) unless @applications.empty?
    unless @remove_applications.empty?
      config.merge!(remove_applications: @remove_applications)
    end
    unless @unattended_upgrades.nil?
      config.merge!(apt: { "unattended_upgrades" => { "enabled" => @unattended_upgrades } })
    end
    config
  end

  # This runlist will be appended to chef solo cook command
  def runlist
    (@roles.map { |m| "role[#{m}]" } + @recipes.map { |m| "recipe[#{m}]" }).join(", ")
  end

  private

  def configure(what, attributes)
    what.merge!(attributes.inject({}, :merge))
  end

  def db_adapter_name(type)
    case type
    when "mysql"
      "mysql2"
    when "postgres"
      "postgresql"
    end
  end

  def add_sudoers
    add(sudoer: @server.username)
  end

  def add_deploy_users
    add(deploy_users: @server.deploy_users)
  end
end
