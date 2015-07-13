require "test_helper"

class ApplyBackupsWorkerTest < ActiveSupport::TestCase
  test "Calls apply_backups on the server_maintainer" do
    ServerMaintainer.any_instance.expects(:apply_backups)
    ApplyBackupsWorker.new.perform(servers(:bootstrapped).id)
  end
end
