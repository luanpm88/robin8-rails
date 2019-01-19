# coding: utf-8
module API
  module V3_0
    class Creations < Grape::API
      resources :creations do
        before do
          authenticate!
        end

        #get creations list
        params do
        	optional :status, type: String
          optional :page,   type: Integer
        end
        get '/' do
        	list = 	if %w(passed ended finished).include?(params[:status])
        						Creation.by_status(params[:status])
        					else
        						Creation.alive
        					end

        	list =  list.page(params[:page]).per_page(10)

        	present :error, 0
        	present :list,  list, with: API::V3_0::Entities::CreationEntities::BaseInfo
        end

        # get simple creation detail
        params do
        	requires :id, type: Integer
        end
        get ':id' do
        	creation = Creation.find_by(params[:id])

        	error_403!(detail: '查无此活动，请规范使用APP') unless creation.try(:is_alive?)

        	present :error,    0
        	present :creation, creation, with: API::V3_0::Entities::CreationEntities::Detail
        end

        # tender
        params do
        	requires :id,          type: Integer
        	requires :tenders_ary, type: Array[JSON] do
            requires :from_terrace, type: String
            requires :price, 				type: Float
          end
        end
        post ':id/tender' do
        	# 判断是否是大V
        	error_403!(detail: '申请成为大V用户，让你的钱包更丰满') unless current_kol.role_apply_status != 'passed'

        	creation = Creation.find_by(params[:id])

        	error_403!(detail: '查无此活动，请规范使用APP') unless creation.try(:is_alive?)
        	error_403!(detail: '您只能在活动有效时间内报价') if Time.now < creation.start_at || Time.now > creation.end_at

        	if Tender.where(kol_id: current_kol.id, creation_id: craetion.id).map(&:status).uniq != ['pending']
        		error_403!(detail: '您的报价已无法修改')
        	end

        	selected_kol = CreationSelectedKol.find_by(creation_id: creation.id, kol_id: current_kol.id)

        	params[:tenders_ary].each do |_hash|
        		t = Tender.find_or_initialize_by(
        					creation_id:   creation.id,
        					kol_id: 		   current_kol.id,
        					from_terrace:  _hash[:from_terrace],
        				)
        		if _hash[:price] == 0
        			t.delete unless t.new_record?
        		else
        			t.price 										= _hash[:price]
        			t.fee 										  = _hash[:price] * creation.fee_rate
        			t.creation_selected_kol_id 	= selected_kol.try(:id)
        			t.save
        		end
        	end

        	present :error, 0
        end

        # upload links
        params do
        	requires :id, type: Integer
        	requires :links_ary,   type: Array[JSON] do
            requires :from_terrace, type: String
            requires :link, 				type: String
          end
        end
        post ':id/upload_links' do
        	creation = Creation.find_by(params[:creation_id])

        	params[:links_ary].each do |_hash|
        		t = Tender.find_by(
        					creation_id:   creation.id,
        					kol_id: 		   current_kol.id,
        					from_terrace:  _hash[:from_terrace],
        				)
        		if t.can_upload?
        			t.update_attributes(link: _hash[:link], status: 'uploaded')
        			t.climb_info # 上传链接后抓一遍数据
        		end
        	end

        	present :error, 0
        end

        # upload reports
        params do
        	requires :creation_id, type: Integer
        	requires :reports_ary, type: Array[JSON] do
            requires :from_terrace, type: String
            requires :image_url, 	  type: File
          end
        end
        post ':creation_id/upload_reports' do
        	creation = Creation.find_by(params[:creation_id])

        	params[:reports_ary].each do |_hash|
        		t = Tender.find_by(
        					creation_id:   creation.id,
        					kol_id: 		   current_kol.id,
        					from_terrace:  _hash[:from_terrace],
        				)
        		# upload report
        	end

        	present :error, 0
        end 

      end
    end
  end
end