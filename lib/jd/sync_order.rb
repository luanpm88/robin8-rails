module Jd
  class SyncOrder
    # 每15分钟需同步一下近一个小时的数据,如果该15分钟横跨小时,需要同步最近两个小时内的数据
    def self.schedule_sync
      Rails.logger.jd.info "------SyncCommision.SyncOrder"
      last_query_time = (Time.now - 20.minutes).strftime("%Y%m%d%H")
      sync_by_time(last_query_time)
      query_time = Time.now.strftime("%Y%m%d%H")
      sync_by_time(query_time) if  query_time !=  last_query_time
    end

    def self.sync_by_time(query_time = Time.now.strftime("%Y%m%d%H"))
      res = Service.query_orders(query_time)
      if res["success"] == 1
        res["data"].each do |order_data|
          order = CpsPromotionOrder.find_or_initialize_by(:order_id => order_data["orderId"])
          next if !order.new_record?  && order.yn == 0
          if order.new_record?
            order.sub_union = order_data["subUnion"]
            sub_union_arr = order.sub_union.split("_")
            order.kol_id = sub_union_arr[0]
            order.cps_article_share_id = sub_union_arr[1]
            order.order_query_time =  query_time
            order.split_type = order_data["SplitType"]
            order.order_time = order_data["orderTime"]
            order.parent_id = order_data["parentId"]
            order.pop_id = order_data["popId"]
            order.source_emt = order_data["sourceEmt"]
            order.total_money = order_data["totalMoney"]
            order.cos_price = order_data["cosPrice"]
            order.yn = order_data["yn"]
            if order_data["yn"] == 1
              order.status = 'pending'
            else
              order.status = 'canceled'
            end
            order_data["details"].each do |item|
              order.cps_promotion_order_items.build(first_level: item["firstLevle"],
                                                   second_level: item["secondLevel"],
                                                   third_level: item["thirdLevle"],
                                                   total_price: item["totalPrice"],
                                                   ware_id: item["wareId"],
                                                   yg_cos_fee: item["ygCosFee"],
                                                   quantity: item["quantity"],
                                                   product_id: item["productId"]
              )
            end
          else
            order.yn = order_data["yn"]
            if order.status == 'pending' &&  order_data["yn"] != 1
              order.status = 'canceled'
              order.cancel_query_time = query_time
            end
          end
          order.save!
        end
      else
        Rails.logger.jd.info "=======sync_add---error"
      end
    end

    #每天同步一次近10天的历史
    def self.schedule_sync_history
      start_query_time = (Time.now - 10.days).beginning_of_day.strftime("%Y%m%d%H")
      query_time_arr = CpsPromotionOrder.where(:yn => 1).where("order_query_time >= '#{start_query_time}'").collect{|t| t.order_query_time}.uniq.sort
      query_time_arr.each do |query_time|
        sync_by_time(query_time)
      end
    end
  end
end
