class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :subscription, index: true
      t.string :country
      t.integer :vat
      t.integer :amount

      t.timestamps
    end
  end
end
