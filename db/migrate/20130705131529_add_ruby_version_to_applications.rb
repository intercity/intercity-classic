class AddRubyVersionToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :ruby_version, :string, default: '2.0.0-p195'
  end
end
