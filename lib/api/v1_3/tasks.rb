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
          invite_code = current_kol.kol_invite_code
          unless invite_code.present?
            invite_code = KolInviteCode.create(code: create_random_code , kol_id: current_kol.id)   rescue nil
          end
          present :error, 0
          # invite_count = current_kol.task_records.invite_friend.count
          # invite_amount = current_kol.invite_transactions.sum(:credits)
          present :invite_count, current_kol.children.count 
          present :invite_amount, current_kol.children.count * 2.0 + current_kol.friend_gains.sum(:credits)
          present :invite_code , invite_code.code
        end
      end
    end
  end
end
