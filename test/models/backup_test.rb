require "test_helper"

class BackupTest < ActiveSupport::TestCase
  should belong_to :application

  test "fixtures should be valid" do
    Backup.all.each do |backup|
      assert backup.valid?, "Backup #{backup.inspect} should be valid"
    end
  end
end
