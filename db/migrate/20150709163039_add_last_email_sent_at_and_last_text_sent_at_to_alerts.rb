class AddLastEmailSentAtAndLastTextSentAtToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :last_email_sent_at, :datetime
    add_index :alerts, :last_email_sent_at
    add_column :alerts, :last_text_sent_at, :datetime
    add_index :alerts, :last_text_sent_at
  end
end
