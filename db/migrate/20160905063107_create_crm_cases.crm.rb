# This migration comes from crm (originally 20160901075113)
class CreateCrmCases < ActiveRecord::Migration
  def change
    create_table :crm_cases do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
