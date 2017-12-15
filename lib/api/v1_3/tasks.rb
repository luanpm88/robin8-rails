module API
  module V1_3
    class Tasks < Grape::API
      resources :tasks do
        before do
          authenticate!
        end

        #旧签到接口
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

        #旧签到历史接口
        get 'check_in_history' do
         present :error, 0
         present :continuous_checkin_count, current_kol.continuous_checkin_count
         present :today_had_check_in, current_kol.today_had_check_in?
         present :checkin_history, current_kol.checkin_history
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
