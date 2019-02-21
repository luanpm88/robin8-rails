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
        	present :list,  list, with: API::V3_0::Entities::CreationEntities::BaseInfo, kol_id: current_kol.id
        end

        # get simple creation detail
        params do
        	requires :id, type: Integer
        end
        get ':id' do
        	creation = Creation.find_by(id: params[:id])

          error_403!(detail: '查无此活动，请规范使用APP') unless creation.try(:is_alive?)

          selected_kol = CreationSelectedKol.find_by(creation_id: creation.id, kol_id: current_kol.id)

        	present :error,    0
        	present :creation, creation, with: API::V3_0::Entities::CreationEntities::Detail, selected_kol: selected_kol
        end

        # tender
        params do
        	requires :id,          type: Integer
        	requires :tenders_ary, type: String # json
        end
        post ':id/tender' do
          # 判断是否是大V
        	error_403!(detail: '申请成为大V用户，让你的钱包更丰满') if current_kol.role_apply_status != 'passed'

        	creation = Creation.find_by(id: params[:id])

        	error_403!(detail: '查无此活动，请规范使用APP') unless creation.try(:is_alive?)
        	error_403!(detail: '您只能在活动有效时间内报价') if Time.now < creation.start_at || Time.now > creation.end_at

        	selected_kol = CreationSelectedKol.find_by(creation_id: creation.id, kol_id: current_kol.id)

          if selected_kol
            if %w(preelect pending).include?(selected_kol.status)
            else
              error_403!(detail: '您的报价已无法修改')
            end
          end

        	JSON(params[:tenders_ary]).each do |_hash|
        		t = Tender.find_or_initialize_by(
        					creation_id:   creation.id,
        					kol_id: 		   current_kol.id,
        					from_terrace:  _hash['from_terrace'],
        				)
        		if _hash[:price] == 0
        			t.delete unless t.new_record?
        		else
        			t.price 										= _hash['price']
        			t.fee 										  = _hash['price'].to_f * creation.fee_rate
        			t.creation_selected_kol_id 	= selected_kol.try(:id)
        			t.save
        		end
        	end

        	present :error, 0
        end

        # upload links
        params do
        	requires :id,          type: Integer
        	requires :links_ary,   type: String # json
        end
        post ':id/upload_links' do
        	creation = Creation.find_by(id: params[:id])

          selected_kol = CreationSelectedKol.find_by(creation_id: creation.id, kol_id: current_kol.id)

          if selected_kol
            if %w(paid uploaded).include?(selected_kol.status)
            else
              error_403!(detail: '您已无法提交作品。')
            end
          end

        	JSON(params[:links_ary]).each do |_hash|
        		t = Tender.find_by(
        					creation_id:   creation.id,
        					kol_id: 		   current_kol.id,
        					from_terrace:  _hash['from_terrace'],
        				)
        		
        		t.update_attributes(link: _hash['link'])
        		t.climb_info # 上传链接后抓一遍数据
        	end

          selected_kol.reload

          selected_kol.update_attributes(status: :uploaded) unless selected_kol.tenders.map(&:link).uniq == [nil]

        	present :error, 0
        end

      end
    end
  end
end