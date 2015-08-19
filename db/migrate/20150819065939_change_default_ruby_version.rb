class ChangeDefaultRubyVersion < ActiveRecord::Migration
  def change
    change_column_default :onboardings, :ruby_version, "2.2.3"
  end
end
