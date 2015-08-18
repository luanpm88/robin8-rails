namespace :alert do
  desc "Notify users about new stories via email"
  task :notify_users_via_email => :environment do
    where_clause = <<-SQL
      enabled = ? AND email IS NOT NULL AND email != ''
    SQL
    Alert.includes(:stream)
      .where(where_clause, true).find_in_batches do |group|
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
    SQL
    Alert.includes(:stream)
      .where(where_clause, true).find_in_batches do |group|
      group.each do |alert|
        if !alert.stream.last_seen_story_at.blank? &&
          alert.stream.sort_column == "published_at"
          TextAlertWorker.perform_async(alert.id)
        end
      end
    end
  end

  desc "Notify kols about wechat report"
  task :notify_kols_via_email => :environment do
    Article.includes(:campaign).where("tracking_code IS NOT NULL AND tracking_code!='Waiting'").find_in_batches do |group|
      group.each do |item|
        report = WechatArticlePerformance.where(:article_id => item.id).order(created_at: :desc).first
        unless report.blank?
          if (Date.today - report.created_at.to_date).to_i == 8
            kol = Kol.where(:id => item.kol_id).first
            KolMailer.send_wechat_report_alert(kol.email, kol.first_name, kol.last_name, item.campaign.name).deliver_now
          end
        else
          if (Date.today - item.updated_at.to_date).to_i == 8
            kol = Kol.where(:id => item.kol_id).first
            KolMailer.send_wechat_report_alert(kol.email, kol.first_name, kol.last_name, item.campaign.name).deliver_now
          end
        end
      end
    end
  end

end
