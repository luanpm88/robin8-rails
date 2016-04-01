# Reports::Kols.signup_count_from_every_channel "2016-3-28".to_date, "2016-4-2".to_date
module Reports
  module Kols
    extend self
    def signup_count_from_every_channel start_day, end_day
      # 每一天的 每个渠道的注册数目去掉重复的个数(在同一个设备 注册多个时间号， 只算首次的时间)
      stats = {}
      kols = Kol.where("created_at > ?", start_day.to_time).order("created_at asc")
      stats[:total_count] = kols.count
      stats[:device_tokens] = {}
      stats[:imes] = {}

      kols.each do |kol|
        stats = incr_every_day_total_uniq_signup_count stats, kol
        stats = incr_every_day_total_signup_count stats, kol
      end
      output_reports stats, start_day, end_day
      return
    end

    def incr_every_day_total_signup_count stats, kol
      total_key = "#{kol.created_at.to_date}:total_count".to_sym
      stats[total_key] = stats[total_key].to_i + 1

      if kol.utm_source
        channel_key = "#{kol.created_at.to_date}:channel:total_count".to_sym
        stats[channel_key] ||= {}
        stats[channel_key][kol.utm_source] ||= [0, 0]
        stats[channel_key][kol.utm_source][0] = stats[channel_key][kol.utm_source][0] + 1
      end
      stats
    end

    def incr_every_day_total_uniq_signup_count stats, kol
      uniq_total_key = "#{kol.created_at.to_date}:uniq:total_count".to_sym
      channel_key = "#{kol.created_at.to_date}:channel:total_count".to_sym

      if kol.device_token
        if not stats[:device_tokens][kol.device_token]
          stats[uniq_total_key] = stats[uniq_total_key].to_i + 1
          if kol.utm_source
            stats[channel_key] ||= {}
            stats[channel_key][kol.utm_source] ||= [0, 0]
            stats[channel_key][kol.utm_source][1] = stats[channel_key][kol.utm_source][1] + 1
          end
        end
      elsif kol.IMEI.present?
        if not stats[:imes][kol.IMEI]
          stats[uniq_total_key] = stats[uniq_total_key].to_i + 1
        end
        if kol.utm_source
          if kol.utm_source
            stats[channel_key] ||= {}
            stats[channel_key][kol.utm_source] ||= [0, 0]
            stats[channel_key][kol.utm_source] = stats[channel_key][kol.utm_source][1] + 1
          end
        end
      else
        stats[:imei_and_token_not_exist] = stats[:imei_and_token_not_exist].to_i + 1
      end

      stats[:device_tokens][kol.device_token] = stats[:device_tokens][kol.device_token].to_i + 1 if kol.device_token
      stats[:imes][kol.IMEI] = stats[:imes][kol.IMEI].to_i + 1 if kol.IMEI
      stats
    end

    def output_reports stats, start_day, end_day
      diff_day = (end_day - start_day).to_i
      diff_day.times.each do |index|
        day = (start_day + index).to_date.to_s
        puts '-'*15 + day + "-"*15

        total_key = "#{day}:total_count".to_sym
        puts "注册总数: #{stats[total_key]}"

        uniq_total_key = "#{day}:uniq:total_count".to_sym
        puts "唯一的注册数: #{stats[uniq_total_key]}"

        channel_key = "#{day}:channel:total_count".to_sym
        stats[channel_key].to_a.sort_by do |i| i[1][1] end.each  do |item|
          puts "渠道名字: #{item[0]},  总注册数: #{item[1][0]}, 唯一注册数: #{item[1][1]}"
        end
        puts '-'*15 + "#{day}-end" + "-"*15
      end
    end
  end
end