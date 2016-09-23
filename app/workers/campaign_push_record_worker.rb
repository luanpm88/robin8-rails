class CampaignPushRecordWorker
  include Sidekiq::Worker

  def perform(campaign_id, type=nil, kols=[])
    @campaign = Campaign.find(campaign_id) rescue nil

    if type == 'common'
      if @campaign.is_invite_type? && @campaign.get_social_account_related_kol_ids #针对特邀活动，指定了特定的社交账号，通过社交账号来找到KOL
        @campaign.get_social_account_related_kol_ids.each_slice(5000) do |kol_ids|
          inserts = []
          kol_ids.each do |kol_id|
            inserts.push "(#{@campaign.id}, #{kol_id}, 'common', True, '特邀活动指定特定kol')"
          end
          sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
          ActiveRecord::Base.connection.execute(sql)
          # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: true, success_reason: '特邀活动指定特定kol')
        end
      elsif @campaign.get_specified_kol_ids
        @campaign.get_specified_kol_ids.each_slice(5000) do |kol_ids|
          inserts = []
          kol_ids.each do |kol_id|
            inserts.push "(#{@campaign.id}, #{kol_id}, 'common', True, '指定kols')"
          end
          sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
          ActiveRecord::Base.connection.execute(sql)
          # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: true, success_reason: '指定kols')
        end
      elsif @campaign.get_matching_kol_ids
        save_matched_kols
        save_removed_kols_by_specified_campaign
        save_specify_removed_kols
        save_black_list_kols
        save_today_receive_three_times_kols
        save_frequent_push_kols
      end

    elsif type == 'append'
      @campaign.get_append_kol_ids.each_slice(5000) do |kol_ids|
        inserts = []
        kol_ids.each do |kol_id|
          inserts.push "(#{@campaign.id}, #{kol_id}, 'append', True, '定时补推')"
        end
        sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
        ActiveRecord::Base.connection.execute(sql)
        # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'append', success: true, success_reason: '定时补推')
      end
    elsif type == 'push_all'
      if kols.present?
        kols.each_slice(5000) do |kol_ids|
          inserts = []
          kol_ids.each do |kol_id|
            inserts.push "(#{@campaign.id}, #{kol_id}, 'push_all', True, '全推')"
          end
          sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
          ActiveRecord::Base.connection.execute(sql)
          # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'push_all', success: true, success_reason: '全推')
        end
      end
    end
  end

  def save_matched_kols
    @campaign.get_matching_kol_ids.each_slice(5000) do |kol_ids|
      inserts = []
      kol_ids.each do |kol_id|
        inserts.push "(#{@campaign.id}, #{kol_id}, 'push_all', True, 'default')"
      end
      sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
      ActiveRecord::Base.connection.execute(sql)
      # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: true, success_reason: 'default')
    end
  end

  def save_removed_kols_by_specified_campaign # 参与指定活动的kol
    @campaign.get_remove_kol_ids_of_campaign_by_target.each_slice(5000) do |kol_ids|
      inserts = []
      kol_ids.each do |kol_id|
        inserts.push "(#{@campaign.id}, #{kol_id}, 'common', False, '过滤条件: 去掉参与指定活动的kol')"
      end
      sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
      ActiveRecord::Base.connection.execute(sql)
      # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: false, fail_reason: '过滤条件: 去掉参与指定活动的kol')
    end
  end

  def save_specify_removed_kols #指定的kol
    @campaign.get_remove_kol_ids_by_target.each_slice(5000) do |kol_ids|
      inserts = []
      kol_ids.each do |kol_id|
        inserts.push "(#{@campaign.id}, #{kol_id}, 'common', False, '过滤条件: 去掉指定的kol')"
      end
      sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
      ActiveRecord::Base.connection.execute(sql)
      # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: false, fail_reason: '过滤条件: 去掉指定的kol')
    end
  end

  def save_black_list_kols  # 黑名单中的kol
    @campaign.get_black_list_kols.each_slice(5000) do |kol_ids|
      inserts = []
      kol_ids.each do |kol_id|
        inserts.push "(#{@campaign.id}, #{kol_id}, 'common', False, '黑名单')"
      end
      sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
      ActiveRecord::Base.connection.execute(sql)
      # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: false, fail_reason: '黑名单')
    end
  end

  def save_today_receive_three_times_kols # 一天接了3单的Kol
    @campaign.today_receive_three_times_kol_ids.each_slice(5000) do |kol_ids|
      inserts = []
      kol_ids.each do |kol_id|
        inserts.push "(#{@campaign.id}, #{kol_id}, 'common', False, '一天接了3单')"
      end
      sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
      ActiveRecord::Base.connection.execute(sql)
      # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: false, fail_reason: '一天接了3单')
    end
  end

  def save_frequent_push_kols # 推送过于频繁
    @campaign.three_hours_had_receive_kol_ids.each_slice(5000) do |kol_ids|
      inserts = []
      kol_ids.each do |kol_id|
        inserts.push "(#{@campaign.id}, #{kol_id}, 'common', False, '推送过于频繁(2小时推一次)')"
      end
      sql = "INSERT INTO campaign_push_records(campaign_id, kol_id, push_type, success, success_reason) values #{inserts.join(',')}"
      ActiveRecord::Base.connection.execute(sql)
      # CampaignPushRecord.create!(campaign_id: @campaign.id, kol_id: kol_id, push_type: 'common', success: false, fail_reason: '推送过于频繁(2小时推一次)')
    end
  end

end
