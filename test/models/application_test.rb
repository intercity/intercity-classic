require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :rails_environment
  should validate_uniqueness_of(:name).scoped_to(:server_id)
  should allow_value("valid_name").for(:name)
  should_not allow_value("invalid name").for(:name)
  should have_many :env_vars
  should have_one :backup

  test "All fixtures are valid" do
    Application.all.each do |app|
      assert app.valid?, "App #{app.name} fixture should be valid"
    end
  end

  test "Name uniqueness validation should only check for not deleted apps" do
    app = applications(:intercity_beta)
    assert app.valid?, "App should be valid"

    app2 = app.dup
    refute app2.valid?, "App2 should not be valid since app 1 still exists"

    app.destroy!
    assert app2.valid?, "App 2 should be valid since app 1 is deleted"
  end

  test "Validates ssl_cert and ssl_key presence when SSL is turned on" do
    app = applications(:intercity_beta)
    app.enable_ssl = true
    app.validate_ssl = true
    refute app.valid?, "App should not be valid without ssl_cert and ssl_key"

    app.ssl_cert = "invalid_ssl"
    app.ssl_key = "invalid_key"
    refute app.valid?, "App should not be valid without valid ssl cert and key"

    app.ssl_cert = File.read("test/fixtures/files/certificate.crt")
    app.ssl_key = File.read("test/fixtures/files/certificate.key")
    assert app.valid?, "App should be valid with valid SSL information"
  end

  test "create generates database username and password" do
    application = Application.create(name: "ourapp_production")

    assert !application.database_user_encrypted.blank?
    assert !application.database_password_encrypted.blank?
  end

  test "create fills db host and name" do
    application = Application.new(name: "intercity_production")

    application.save!

    assert_equal "localhost", application.database_host
    assert_equal "intercity_production", application.database_name
  end

  test "#formatted_env_vars returns the env vars in hash format" do
    application = applications(:intercity_beta)
    expected_hash = { "rails_env" => "acceptance", "secret_key" => "abcd" }
    assert_equal expected_hash, application.formatted_env_vars

    empty_app = Application.new
    expected_hash = {}
    assert_equal expected_hash, empty_app.formatted_env_vars
  end

  test "connect_to_database_from_application links to a valid app on the server" do
    application = applications(:intercity_beta)
    application_from_other_server = applications(:chef_builder_app1)

    application.use_database_from_other_application = true
    application.valid?
    assert_equal ["can't be blank"], application.errors.messages[:connect_to_database_from_application_id]

    application.connect_to_database_from_application = application_from_other_server

    application.valid?
    assert_equal ["is not available on this server"], application.errors.messages[:connect_to_database_from_application_id], "Expected application to be invalid because database is connected to an application not on this server"
  end

  test "After creating an application the backup strategy should be created" do
    app = applications(:intercity_beta).dup
    assert_difference "Backup.count" do
      app.name = "backup_tester"
      app.save!
    end
  end

  test "After creating an application the rails secret ENV Var should be created" do
    app = applications(:intercity_beta).dup
    assert_difference "EnvVar.count" do
      app.name = "envvar_tester"
      app.save!
    end
    assert_equal "SECRET_KEY_BASE", app.env_vars.first.key
  end

  test "#mark_as_deleting should set deleting to true" do
    app = applications(:intercity_beta)
    refute app.deleting?, "App should not be marked as deleting"
    app.mark_as_deleting
    assert app.deleting?, "App should be marked as deleting"
  end
end
