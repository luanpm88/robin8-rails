class CreateCrmCases < ActiveRecord::Migration
  def change
    create_table :crm_cases do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
