class SetCurrentServersToApplied < ActiveRecord::Migration
  def change
    Server.find_each do |server|
      if server.applied_at.nil?
        server.update_column(:applied_at, server.updated_at)
      end
    end
  end
end
