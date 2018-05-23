class CreateStatisticsKolIncomes < ActiveRecord::Migration
  def change
    create_table :statistics_kol_incomes do |t|
      t.integer :kol_id
      t.string :admintag
      t.float :cpc_income
      t.integer :cpc_count
      t.float :cpp_income
      t.integer :cpp_count
      t.float :cpt_income
      t.integer :cpt_count
      t.float :day_of_income
      t.integer :day_of_count
      t.datetime :action_at
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps null: false
    end
  end
end
