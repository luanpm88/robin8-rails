class LotteryDrawWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3
  sidekiq_retry_in do |count|
    50 * (count + 1) * (count + 1)
  end

  def perform(code)
    activity = LotteryActivity.where(code: code).take
    Rails.logger.sidekiq.info "夺宝活动开奖 编号：#{code}"

    activity.with_lock do
      raise "夺宝活动开奖异常，活动状态异常！" unless activity.status === "drawing"
#= begin 弃用开彩网
#       number_a = LotteryActivityOrder.paid.ordered.limit(10).inject(0) do |sum, o|
#        sum += o.code.to_i
#       end

#       number_b = '%05d' % rand(10 **5).to_i
#       number_b_issue = ""

#       retries = 0
#       begin
#         # 接口来自 http://www.opencai.net/apifree/
#         res = RestClient::Request.execute(:method => :get,
#                                   :url => Rails.application.secrets[:lottery][:api_url],
#                                   :timeout => 10,
#                                   :open_timeout => 10)

#         rest = JSON.parse(res)
#         raise "获取网络上彩票开奖号码数据解析异常" unless rest["data"] and rest["data"].size > 0
#         data = rest["data"].first
#         number_b = data["opencode"].split(",").join("").to_i
#         number_b_issue = data["expect"]
#       rescue => e
#         # response code 408 is 'Request Timeout'
#         if (res.nil? or res.code == 408) and retries < 3
#           retries += 1
#           retry
#         else
#           raise "夺宝活动开奖异常，获取网络上彩票开奖号码出错: #{e.inspect}"
#         end
#       end



#       lucky_number = activity.generate_lucky_number(number_a + number_b)
#       ticket = activity.tickets.where(code: lucky_number).take
#= end
      ticket = activity.tickets.sample
      raise "夺宝活动开奖异常，无法找到所摇奖券！" unless ticket

      order = ticket.lottery_activity_order
      raise "夺宝活动开奖异常，无法找到所摇奖券对应的订单！" unless order

      kol = order.kol
      raise "夺宝活动开奖异常，无法找到所摇奖券对应的用户！" unless kol

      activity.update!({
        status: "finished",
        lucky_kol: kol,
        lucky_number: ticket.code,
        draw_at: Time.now,
        order_sum: activity.orders.count,
        lottery_number: ticket.code,
        lottery_issue: ''
      })

      activity.deliver
      activity.lottery_product.pub
    end
  end

end
