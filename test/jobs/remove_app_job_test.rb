require "test_helper"
class RemoveAppJobTest < ActiveJob::TestCase
  test "it calls out to SSH execution" do
    app = applications(:intercity_beta)
    ServerMaintainer.any_instance.expects(:remove_application).with(app)
    RemoveAppJob.perform_now app.id
  end
end
