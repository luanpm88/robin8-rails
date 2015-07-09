namespace :alert do
  desc "Notify users about new stories via email"
  task :notify_users_via_email => :environment do
    where_clause = <<-SQL
      enabled = ? AND email IS NOT NULL AND email != ''
      AND (last_email_sent_at IS NULL OR last_email_sent_at < ?)
    SQL
    Alert.includes(:stream)
      .where(where_clause, true, 3.hours.ago.utc).find_in_batches do |group|
      group.each do |alert|
        if !alert.stream.last_seen_story_at.blank? && 
          alert.stream.sort_column == "published_at"
          EmailAlertWorker.perform_async(alert.id)
        end
      end
    end
  end
  
  desc "Notify users about new stories via text messages"
  task :notify_users_via_text => :environment do
    where_clause = <<-SQL
      enabled = ? AND phone IS NOT NULL AND phone != ''
      AND (last_text_sent_at IS NULL OR last_text_sent_at < ?)
    SQL
    Alert.includes(:stream)
      .where(where_clause, true, 6.hours.ago.utc).find_in_batches do |group|
      group.each do |alert|
        if !alert.stream.last_seen_story_at.blank? && 
          alert.stream.sort_column == "published_at"
          TextAlertWorker.perform_async(alert.id)
        end
      end
    end
  end
end
