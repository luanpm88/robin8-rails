module Brand
  module V2
    class TendersAPI < Base
      group do
        before do
          authenticate!
        end

        resource :tenders do

          desc 'create tender for the head'
          params do
            requires :tenders_ary, type: Array
          end

          post ':creation_id/tender' do
            tenders = Tender.where(id: params[:tenders_ary])
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

        end
      end
    end
  end
end