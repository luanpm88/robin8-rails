class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message_type
      t.string :is_read, :default => false
      t.datetime :read_at
      t.string :title
      t.string :desc
      t.string :url
      t.string :logo_url


      # t.string :sender_type
      # t.integer :sender_id
      t.string :sender

      t.string :receiver_type
      t.integer :receiver_id

      t.string :item_type
      t.string :item_id




      t.timestamps null: false
    end
  end
end
