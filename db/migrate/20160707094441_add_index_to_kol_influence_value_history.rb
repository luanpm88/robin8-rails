class AddIndexToKolInfluenceValueHistory < ActiveRecord::Migration
  def change
    add_index :kol_influence_value_histories, :kol_id
  end
end
