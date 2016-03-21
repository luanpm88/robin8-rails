class CreateKolInfluenceValues < ActiveRecord::Migration
  def change
    create_table :kol_influence_values do |t|
      t.integer :kol_id
      t.string :kol_uuid
      t.string :name
      t.string :avatar_url
      t.string :influence_score
      t.string :influence_level

      t.integer :location_score
      t.integer :mobile_model_score
      t.integer :identity_score
      t.integer :identity_count_score
      t.integer :contact_score

      t.timestamps null: false
    end
  end
end
