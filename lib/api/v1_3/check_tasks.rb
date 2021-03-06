module API
  module V1_3
    class CheckTasks < Grape::API
       resources :check_tasks do
        before do
          authenticate!
        end

        #新签到接口
        put 'check_in' do
          if current_kol.today_had_check_in?
            return error_403!({error: 1, detail: '您今日已经签到！' })
          else
            current_kol.new_check_in
            present :error, 0
          end
        end

        #新签到历史接口
        get 'check_in_history' do
          # 验证昨天是否签到，如果没有，重置为0
          current_kol.yesterday_had_check_in?
          # 满7天且今日未签到重置为0
          current_kol.check_in_7_had?

          present :error, 0
          present :continuous_checkin_count,current_kol.continuous_attendance_days
          present :today_had_check_in,      current_kol.today_had_check_in?
          present :checkin_history,         current_kol.new_checkin_history
          present :total_check_in_days,     current_kol.task_records.check_in.active.size
          present :total_check_in_amount,   current_kol.total_check_in_amount
          present :today_already_amount,    current_kol.today_already_amount
          present :today_can_amount,        current_kol.today_can_amount
          present :tomorrow_can_amount,     current_kol.tomorrow_can_amount
          present :check_in_7,              current_kol.check_in_7
          present :campaign_invites_count,  current_kol.campaign_invites.today.count
          present :invite_friends,          current_kol.today_invite_count
          present :is_show_newbie,          current_kol.strategy[:tag] == 'Geometry'
          present :red_money_count,         current_kol.transactions.recent(Time.now, Time.now).subjects('red_money').count
        end

      end
    end
   end
end
