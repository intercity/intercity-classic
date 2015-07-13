require "test_helper"

class BackupFetchServiceTest < ActiveSupport::TestCase
  setup do
    @app = backups(:enabled).application
    setup_s3_mocking
  end

  test "It returns a hash when given an array of apps" do
    backups = BackupFetchService.new(@app).execute
    assert_kind_of Hash, backups
  end

  test "It returns a hash with the app name as keys" do
    backups = BackupFetchService.new(@app).execute
    assert_includes backups.keys, @app.name
  end

  test "It returns the last 5 backups created" do
    backups = BackupFetchService.new(@app).execute
    assert_equal 5, backups[@app.name].count
  end

  private

  def setup_s3_mocking
    Fog.mock!
    @connection = Fog::Storage.new(provider: "AWS",
                                   aws_access_key_id: @app.backup.s3_access_key,
                                   aws_secret_access_key: @app.backup.s3_secret_access_key,
                                   region: @app.backup.s3_region)
    @connection.reset_data
    @connection.directories.create(key: "#{@app.backup.s3_bucket}")
    (1..10).each do |i|
      Timecop.travel(Time.now + i.minutes)
      @connection.put_object("#{@app.backup.s3_bucket}",
                             "intercitybackups/#{@app.name}/#{DateTime.now}/backup-#{i}",
                             "content")
    end
  end
end
