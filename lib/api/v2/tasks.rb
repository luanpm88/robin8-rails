module API
  module V2
    class Tasks < Grape::API
      resources :tasks do
        before do
          authenticate!
        end

        get 'task_list' do
          tasks = RewardTask.all
          present :error, 0
          present :tasks, tasks, with: API::V2::Entities::RewardTaskEntities::Summary, kol: current_kol
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

        #签到
        put 'complete_info' do
          if current_kol.had_complete_info?
            return error_403!({error: 1, detail: '您已经完善过资料！' })
          else
            current_kol.complete_info
            present :error, 0
          end
        end

        # 上传评价截图
        put 'upload_comment_screenshot' do
          required_attributes! [:screenshot]
          if current_kol.had_favorable_comment?
            return error_403!({error: 1, detail: '您已经评价过！' })
          else
            current_kol.upload_comment_screenshot(params[:screenshot])
          end
        end
      end
    end
  end
end
