require "test_helper"
class RemoveSslCertificateJobTest < ActiveJob::TestCase
  test "It calls out to SSH execution" do
    app = applications(:intercity_beta)
    add_ssl_to(app)
    SshExecution.any_instance.expects(:execute).
      with(command: "sudo su - deploy -c \"rm /u/apps/#{app.name}/shared/" \
               "config/certificate.*\"")
    RemoveSslCertificateJob.perform_now app.id
  end

  test "It schedules the ApplyServerWorker after ssh Execution is done" do
    app = applications(:intercity_beta)
    add_ssl_to(app)
    SshExecution.any_instance.stubs(:execute)
    ApplyServerWorker.expects(:perform_async).with(app.server.id)
    RemoveSslCertificateJob.perform_now app.id
  end
end
