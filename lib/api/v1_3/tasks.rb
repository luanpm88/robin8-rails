module API
  module V1_3
    class Tasks < Grape::API
      resources :tasks do
        before do
          authenticate!
        end

        #签到
        put 'check_in' do
          if current_kol.today_had_check_in?
            return error_403!({error: 1, detail: '您今日已经签到！' })
          else
            current_kol.check_in
            present :error, 0
          end
        end

        #完善资料
        put 'complete_info' do
          if current_kol.had_complete_reward?
            return error_403!({error: 1, detail: '您已经完善过资料！' })
          else
            current_kol.complete_info
            present :error, 0
          end
        end

        get 'check_in_history' do
          present :error, 0
          present :continuous_checkin_count, current_kol.continuous_attendance_days
          present :today_had_check_in, current_kol.today_had_check_in?
          present :checkin_history, current_kol.checkin_history

          present :total_check_in_days, current_kol.task_records.check_in.active.size
          present :total_check_in_amount, current_kol.total_check_in_amount
          present :today_already_amount, current_kol.today_already_amount
          present :today_can_amount, current_kol.today_can_amount
          present :tomorrow_can_amount, current_kol.tomorrow_can_amount
        end

        get 'invite_info' do
          present :error, 0
          invite_count = current_kol.task_records.invite_friend.count
          invite_amount = current_kol.invite_transactions.sum(:credits)
          present :invite_count, invite_count
          present :invite_amount, invite_amount
        end
      end
    end
  end
end
