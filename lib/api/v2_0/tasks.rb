# coding: utf-8
module API
  module V2_0
    class Tasks < Grape::API
      resources :tasks do
        before do
          authenticate!
        end

        post 'finish_newbie' do
	        # 首次分享campaign
	        # 首次查看campaign截图
	        # 首次上传campaign截图
          
          error_403!(detail: '用户无此任务') if current_kol.strategy[:tag] == 'Geometry'

	        if current_kol.finish_newbie
	        	present error: 0, alert: 'successfully'
	        else
	        	present error: 1, detail: 'error'
	        end
        end

      end
    end
  end
end