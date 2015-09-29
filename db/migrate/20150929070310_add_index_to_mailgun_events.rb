class AddIndexToMailgunEvents < ActiveRecord::Migration
  def change
    add_index :mailgun_events, :event_type
    add_index :mailgun_events, :event_time
    add_index :mailgun_events, :sender
    add_index :mailgun_events, :campaign_name
  end
end
