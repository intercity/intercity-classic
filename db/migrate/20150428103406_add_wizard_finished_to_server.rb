class AddWizardFinishedToServer < ActiveRecord::Migration
  class Server < ActiveRecord::Base; end

  def up
    add_column :servers, :wizard_finished, :boolean, default: false
    Server.all.each do |s|
      s.wizard_finished = true
      s.save
    end
  end

  def down
    remove_column :servers, :wizard_finished
  end
end
