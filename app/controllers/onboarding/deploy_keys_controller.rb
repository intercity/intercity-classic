class Onboarding::DeployKeysController < Onboarding::BaseController
  skip_before_action :check_and_redirect_to_correct_step, only: [:new, :create, :show]

  def new
    @onboarding = fetch_onboarding
    unless @onboarding.server.bootstrapped?
      redirect_to setup_install_server_path(@onboarding.id)
      return
    end

    @ssh_key = SshKey.new
    render :new
  end

  def create
    @onboarding = fetch_onboarding
    unless @onboarding.server.bootstrapped?
      redirect_to setup_install_server_path(@onboarding.id)
      return
    end
    @ssh_key = @onboarding.server.ssh_keys.new(params.require(:ssh_key).permit(:key))
    @ssh_key.name = "#{current_user.full_name} ssh key"
    if @ssh_key.save
      @onboarding.server.update(working: true, last_error: nil, wizard_finished: true)
      ApplySshKeysWorker.perform_async(@onboarding.server.id)
      redirect_to setup_apply_deploy_key_path
    else
      flash.now[:error] = "Oops! Looks like the information is not correct."
      render :new
    end
  end

  def show
    @onboarding = fetch_onboarding
  end
end
