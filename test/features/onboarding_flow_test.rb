require "test_helper"

class OnboardingFlowTest < Capybara::Rails::TestCase
  before do
    login_as users(:michiel)
  end

  test "Digitalocean onboarding success path" do
    create_and_test_first_step

    within "form.digitalocean" do
      click_button "Choose"
    end

    onboarding = Onboarding.last

    assert_equal setup_droplet_path, current_path
    assert onboarding.reload.digitalocean?, "Digitalocean should be the provider"
    assert_equal "provider_digitalocean", onboarding.reload.last_finished_step

    select "New York", from: "Region"
    fill_in "onboarding_digitalocean_api_key", with: "12345abc"
    click_button "Continue"

    assert_equal setup_droplet_summary_path, current_path
    assert_equal "12345abc", onboarding.reload.digitalocean_api_key

    assert_difference "users(:michiel).servers.count" do
      click_button "Launch Droplet"
    end

    assert_equal setup_install_server_path(onboarding.id), current_path
    assert_equal "installing", onboarding.reload.last_finished_step
    assert_equal "super_app server", Server.last.name
    assert_equal onboarding.server, Server.last
    assert_equal onboarding.application, Application.last
  end

  test "Custom server onboarding success path" do
    use_javascript_driver
    create_and_test_first_step

    within "form.custom_server" do
      click_button "Choose"
    end

    onboarding = Onboarding.last
    assert_equal setup_custom_server_path, current_path
    assert onboarding.custom_server?, "Custom server should be the provider"
    assert_equal "provider_custom_server", onboarding.last_finished_step

    Socket.any_instance.stubs(:connect).returns(true)
    fill_in "ip", with: "11.22.33.44"
    fill_in "port", with: "22"
    click_button "Test connection"

    assert page.has_content?(/We can reach/)

    SshExecution.any_instance.stubs(:execute).returns("OK")
    click_button "I've installed the key"

    assert page.has_content?(/Server connected/), "Page should have server connected content"

    click_button "Continue"

    assert_equal setup_custom_server_summary_path, current_path

    assert_difference "users(:michiel).servers.count" do
      click_button "Install my Server"
    end

    assert_equal setup_install_server_path(onboarding.id), current_path
    assert_equal "installing", onboarding.reload.last_finished_step
    assert_equal "super_app server", Server.last.name
    assert_equal onboarding.server, Server.last
    assert_equal onboarding.application, Application.last
  end

  test "Correct redirections based on last_finished_step value" do
    login_as users(:michiel)

    assert_redirection_for_step_forward(step: nil, path: setup_app_path)
    assert_redirection_for_step_forward(step: "app", path: setup_provider_path)
    assert_redirection_for_step_forward(step: "provider_digitalocean", path: setup_droplet_path)
    assert_redirection_for_step_forward(step: "installing", path: setup_install_server_path(onboardings(:full).id))
  end

  private

  def assert_redirection_for_step_forward(step: nil, path: nil)
    onboardings(:full).reload.update!(last_finished_step: step)
    page.set_rack_session(onboarding: onboardings(:full).id)

    # Always visit the last most page in the flow, current_path way we can check if we
    # are actually being redirected to the correct step in the flow. (Blegh
    # comments >_< )
    visit setup_install_server_path(onboardings(:full).id)
    assert_equal path, current_path
  end

  def create_and_test_first_step
    visit setup_app_path
    fill_in "App name", with: "super_app"
    select "2.1.2", from: "Ruby version"
    select "PostgreSQL", from: "Database"
    click_button "Continue"

    assert_equal setup_provider_path, current_path

    onboarding = Onboarding.last
    assert_equal "super_app", onboarding.name
    assert_equal "app", onboarding.last_finished_step
  end
end
