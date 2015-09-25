class CreateMailgunEvents < ActiveRecord::Migration
  def change
    create_table :mailgun_events do |t|
      t.string :event_type
      t.datetime :event_time
      t.string :severity
      t.string :sender
      t.string :recipient
      t.string :country
      t.string :campaign_name
      t.text :delivery_status

      t.timestamps
    end
  end
end
