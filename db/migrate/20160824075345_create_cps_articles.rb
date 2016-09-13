class CreateCpsArticles < ActiveRecord::Migration
  def change
    create_table   :cps_articles do |t|
      t.references :kol
      t.string     :title
      t.string     :cover
      t.text       :content

      t.string   :status, :default => 'pending'
      t.datetime :check_time
      t.string   :check_remark

      t.boolean :enabled, :default => true

      t.timestamps null: false
    end
  end
end
