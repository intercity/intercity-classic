require 'test_helper'

class OnboardingTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :server
  should belong_to :application

  should allow_value("valid_name").for(:name)
  should_not allow_value("invalid name").for(:name)

  test "Validate step one" do
    onboarding = Onboarding.new(name: nil, ruby_version: nil, db_type: nil)
    onboarding.validation_step = :new_app

    onboarding.valid?
    errors = onboarding.errors.keys
    assert_equal [:name, :ruby_version, :db_type], errors
  end

  test "Validation new droplet" do
    onboarding = Onboarding.new(digitalocean_region: nil, digitalocean_api_key: nil)
    onboarding.validation_step = :new_droplet

    onboarding.valid?
    errors = onboarding.errors.keys
    assert_equal [:digitalocean_region, :digitalocean_api_key], errors
  end

  test "Onboarding should have same providers as Server" do
    skip "This needs to be mapped"
    assert_equal Server.providers, Onboarding.providers
  end

  test "Onboarding should have the same DO regions as Server" do
    assert_equal Server.digitalocean_regions, Onboarding.digitalocean_regions
  end

  test "#create_server_and_app creates server and app and returns them as hash" do
    onboarding = create_onboarding_object.create_server_and_app
    server = onboarding[:server]
    app = onboarding[:app]

    assert_kind_of Server, server
    assert_kind_of Application, app

    assert server.persisted?, "Server should be saved"
    assert app.persisted?, "App should be saved"

    assert_equal "test_app server", server.name
    assert_equal users(:michiel), server.owner
    assert_equal "postgres", server.db_type

    assert_equal app.server, server
  end

  private

  def create_onboarding_object
    Onboarding.create!(name: "test_app", user: users(:michiel),
                       provider: Onboarding.providers["digitalocean"],
                       digitalocean_region: Onboarding.digitalocean_regions["amsterdam"],
                       db_type: Onboarding.db_types["postgresql"], ruby_version: "2.2.1")
  end
end

