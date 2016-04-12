class CreateKolInfluenceValueHistories < ActiveRecord::Migration
  def change
    create_table :kol_influence_value_histories do |t|

      t.timestamps null: false
    end
  end
end
