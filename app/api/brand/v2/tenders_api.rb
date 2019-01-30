module Brand
  module V2
    class TendersAPI < Base
      group do
        before do
          authenticate!
        end

        resource :tenders do

          desc 'create tender for the head' #创建总报价
          params do
            requires :csk_ary, type: Array
            requires :creation_id, type: Integer
          end

          post "/create" do
            csks = CreationSelectedKol.where(id: params[:csk_ary])
            tenders_ary = []
            csks.each do |csk|
              tenders_ary += csk.tenders.map &:id
            end
            binding.pry
            tenders = Tender.where(id: tenders_ary)
            tender = Tender.new(head: true, creation_id: params[:creation_id])
            tender.price = tenders.sum(:price)
            tender.fee = tenders.sum(:fee)
            tender.sub_tenders << tenders
            # tender.status = "pending" 默认值
            tenders.update_all(status: 'pending')

            if tender.save
              present tender
            else
              present tender.errors.messages
            end
          end




          #验收作品成功
          params do 
            requires :creation_selected_kol_id,  type: String
          end
          post "/update_status" do 
            csk = CreationSelectedKol.find_by_id params[:creation_selected_kol_id]
            if csk
              csk.update_column(:status, "approved")
              present csk, with: Entities::CreationSelectedKol
            else
              return {error: 1, detail: '数据错误，请确认'}
            end
          end


        end
      end
    end
  end
end