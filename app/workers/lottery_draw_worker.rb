class LotteryDrawWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3
  sidekiq_retry_in do |count|
    10 * (count + 1)
  end

  def perform(code)
    activity = LotteryActivity.where(code: code).take
    Rails.logger.sidekiq.info "夺宝活动开奖 编号：#{code}"

    activity.with_lock do
      raise "夺宝活动开奖异常，活动状态异常！" unless activity.status === "drawing"

      number_a = LotteryActivityOrder.ordered.limit(Rails.application.secrets[:lottery][:order_size] || 10).inject(0) do |sum, o|
       sum += o.code.to_i
      end

      number_b = '%05d' % rand(10 **5).to_i
      begin
        # 接口来自 http://www.opencai.net/apifree/
        rest = JSON.parse(RestClient.get(Rails.application.secrets[:lottery][:api_url]))
        raise "夺宝活动开奖异常，获取网络上彩票开奖号码数据异常" unless rest["data"] and rest["data"].size > 0
        data = rest["data"].first
        number_b = data["opencode"].split(",").join("").to_i
      rescue => e
       Rails.logger.sidekiq.error "夺宝活动开奖异常，获取网络上彩票开奖号码出错: #{e.inspect}"
      end

      lucky_number = activity.generate_lucky_number(number_a + number_b)
      ticket = activity.tickets.where(code: lucky_number).take
      raise "夺宝活动开奖异常，无法找到所摇奖券！" unless ticket

      order = ticket.lottery_activity_order
      raise "夺宝活动开奖异常，无法找到所摇奖券对应的订单！" unless order

      kol = order.kol
      raise "夺宝活动开奖异常，无法找到所摇奖券对应的用户！" unless kol

      activity.update!(status: "finished", lucky_kol: kol, lucky_number: lucky_number, draw_at: Time.now)
    end
  end

end
