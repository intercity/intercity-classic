require "test_helper"

class ChefConfigurationBuilderTest < ActiveSupport::TestCase
  test "should create chef configuration" do
    server = Server.new(username: "intercity", db_type: "mysql")
    server.stubs(:deploy_users).returns(["shaniqua", "leeroy"])
    app = applications(:chef_builder_app1)
    app2 = applications(:remove_app)
    add_ssl_to(app)
    builder = ChefConfigurationBuilder.new(server).
              add(role: "rails").add(role: "mysql").
              add(role: "backup").add(role: "remove_applications").
              add(ssh_deploy_key: "ssh-rsa bazabatavatta=").
              rails(applications_root: "/u/a").
              nginxize(client_max_body_size: "21m", foo: "bar").
              application(app).backup_for(app).remove_app(app2)

    assert_equal "role[rails], role[mysql], role[backup], role[remove_applications]", builder.runlist
    assert_equal valid_config, builder.config, "Incorrect configuration"
  end

  test "should build chef configuration with database from another application" do
    application_with_another_database = applications(:intercity_beta)
    application_with_another_database.database_name = "intercity_beta"
    another_application = application_with_another_database.dup
    another_application.database_name = "another_application"
    another_application.save
    server = another_application.server

    # First verify own database
    builder = ChefConfigurationBuilder.new(server).application(application_with_another_database)
    assert_equal "intercity_beta", builder.config[:active_applications]["intercity_beta"][:database_info][:database]

    # Now enable connecting to the other database
    application_with_another_database.use_database_from_other_application = true
    application_with_another_database.connect_to_database_from_application = another_application
    application_with_another_database.save

    builder = ChefConfigurationBuilder.new(server).application(application_with_another_database)
    assert_equal "another_application", builder.config[:active_applications]["intercity_beta"][:database_info][:database]
  end

  private

  def valid_config
    {
      authorization: {
        sudo: {
          users: ["intercity"]
        }
      },
      nginx: {
        client_max_body_size: "21m",
        foo: "bar"
      },
      ssh_deploy_keys: ["ssh-rsa bazabatavatta="],
      deploy_users: ["shaniqua", "leeroy"],
      rails: { applications_root: "/u/a" },
      rbenv: { group_users: ["shaniqua", "leeroy"] },
      backups: {
        "Chef_1" => {
          enabled: true,
          storage_type: "s3",
          s3_access_key: "abc123",
          s3_secret_access_key: "321cba",
          s3_bucket: "testing-bucket",
          s3_region: "eu-west-1",
          database_type: "mysql",
          database_username: nil,
          database_password: nil,
          database_host: "12.23.43.1",
          database_name: "chef1"
        }
      },
      active_applications: {
        "Chef_1" => {
          domain_names: ["chef1.com", "chef2.biz"],
          redirect_domain_names: ["www.chef1.com"],
          client_max_body_size: "200m",
          env_vars: { "env_var_two" => "super key" },
          enable_ssl: true,
          ruby_version: "1.8.7",
          packages: %w(nodejs imagemagick),
          rails_env: "staging",
          deploy_user: "deployer",
          ssl_info: {
            key: ssl[:key],
            crt: ssl[:crt]
          },
          database_info: {
            adapter: "postgresql",
            host: "12.23.43.1",
            username: nil,
            password: nil,
            database: "chef1"
          }
        }
      },
      remove_applications: ["remove"]
    }
  end

  def ssl
    {
      key: File.read("test/fixtures/files/certificate.key"),
      crt: File.read("test/fixtures/files/certificate.crt")
    }
  end
end
