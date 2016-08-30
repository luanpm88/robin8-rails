module Jd
  class SyncCommision
    def self.schedule_sync
      last_query_time = (Time.now - 20.minutes).strftime("%Y%m%d%H")
      sync_by_time(last_query_time)
      query_time = Time.now.strftime("%Y%m%d%H")
      sync_by_time(query_time) if  query_time !=  last_query_time
    end

    def self.sync_by_time(query_time = Time.now.strftime("%Y%m%d%H"))
      res = Service.query_commisions(query_time)
      if res["success"] == 1
        res["data"].each do |order_data|
          CpsPromotionOrder.transaction do
            order = CpsPromotionOrder.find_by(:order_id => order_data["orderId"])
            if order.blank?
              Rails.logger.jd.error "------------SyncCommision----orderId:#{order_data['orderId']}  not found"
              next
            end
            #收到确认收货信息
            if order.receipt_query_time.blank?
              order_data["details"].each do |item|
                order_item = order.cps_promotion_order_items.where(:ware_id => item["wareId"]).first
                next if order_item.blank?
                order_item.return_num = item["returnNum"]
                order_item.cos_fee = item["cosFee"]
                order_item.save
              end
              order.receipt_query_time = query_time
              order.commision_fee = order_data["commisionFee"]
              order.cos_price = order_data["cosPrice"]
              order.status = 'finished'
            elsif order.cos_price !=  order_data["cosPrice"]
              order_data["details"].each do |item|
                order_item = order.cps_promotion_order_items.where(:ware_id => item["wareId"]).first
                next if order_item.blank?
                order_item.return_num = item["returnNum"]
                order_item.cos_fee = item["cosFee"]
                order_item.save
              end
              order.commision_fee = order_data["commisionFee"]
              order.cos_price = order_data["cosPrice"]
              if order_data["cosPrice"] > 0
                order.status = 'part_return'
              elsif order_data["cosPrice"] == 0
                order.status = 'full_return'
              end
            end
            order.save!
          end
        end
      else
        Rails.logger.jd.info "=======sync_add---error"
      end
    end

    def self.schedule_sync_history
      start_query_time = (Time.now - 10.days).beginning_of_day.strftime("%Y%m%d%H")
      query_time_arr = CpsPromotionOrder.where(:yn => 1).where("order_query_time >= '#{start_query_time}'").collect{|t| t.order_query_time}.uniq.sort
      query_time_arr.each do |query_time|
        sync_by_time(query_time)
      end
    end
  end
end
