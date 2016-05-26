module API
  module V1_3
    class LotteryActivities < Grape::API
      resources :lottery_activities do
        before do
          authenticate!
        end

        desc 'get all avaliable lottery activities.'
        params do
          optional :page, type: Integer
        end

        get '/' do
          activities = LotteryActivity.executing.ordered.page(params[:page]).per_page(10)
          to_paginate(activities)
          present :error, 0
          present :activities, activities, with: API::V1_3::Entities::LotteryActivityEntities::Basic
        end

        desc 'show (:code) lottery activity.'
        params do
          requires :code, type: String
        end

        get ':code' do
          activity = LotteryActivity.available.where(code: params[:code]).take
          return {:error => 1, :detail => '无法找到此夺宝活动'} unless activity

          present :error, 0
          present :activity, activity, with: API::V1_3::Entities::LotteryActivityEntities::Show, kol: current_kol
          present :tickets, activity.token_ticket_codes(current_kol)
          present :token_number, activity.token_number(current_kol)
        end

        desc 'show description of (:code) lottery activity.'
        params do
          requires :code, type: String
        end

        get ':code/desc' do
          activity = LotteryActivity.available.where(code: params[:code]).take
          return {:error => 1, :detail => '无法找到此夺宝活动'} unless activity

          present :error, 0
          present :code, activity.code
          present :pictures, activity.lottery_activity_pictures.map(&:url)
        end

        desc 'get order list if (:code) lottery activity.'
        params do
          requires :code, type: String
          optional :page, type: Integer
        end

        get ':code/orders' do
          activity = LotteryActivity.available.where(code: params[:code]).take
          return {:error => 1, :detail => '无法找到此夺宝活动'} unless activity

          orders = activity.orders.paid.ordered.page(params[:page]).per_page(10)
          to_paginate(orders)
          present :error, 0
          present :orders, orders, with: API::V1_3::Entities::LotteryActivityEntities::KolingOrder
        end

        desc 'show drawing formula of (:code) lottery activity.'
        params do
          requires :code, type: String
        end

        get ':code/formula' do
          activity = LotteryActivity.available.where(code: params[:code]).take
          return {:error => 1, :detail => '无法找到此夺宝活动'} unless activity

          present :error, 0
          present :code, activity.code
          present :lucky_number, activity.lucky_number
          present :order_sum, activity.order_sum
          present :lottery_number, activity.lottery_number
          present :lottery_issue, activity.lottery_issue
        end
      end

      resources :lottery_orders do
        before do
          authenticate!
        end

        desc 'create an order'
        params do
          requires :activity_code, type: String
          requires :num, type: Integer
        end

        post '/' do
          activity = LotteryActivity.executing.where(code: params[:activity_code]).take
          return {:error => 1, :detail => '无法找到此夺宝活动'} unless activity
          return {:error => 1, :detail => '抱歉，活动剩余人次不足'} unless activity.enough_tickets? params[:num]

          order = LotteryActivityOrder.new
          order.kol = current_kol
          order.lottery_activity = activity
          order.credits = order.number = params[:num]
          return {:error => 1, :detail => '抱歉，购买出现异常请重试'} unless order.save!

          present :error, 0
          present :order, order, with: API::V1_3::Entities::LotteryActivityEntities::CheckingOrder
        end

        desc 'checkout lottery activity order and pay'
        params do
          requires :code, type: String
        end

        put ':code/checkout' do
          order = LotteryActivityOrder.pending.where(code: params[:code]).take
          return {:error => 1, :detail => '无法找到此订单'} unless order

          begin
            order.checkout
            present :error, 0
            present :order, order, with: API::V1_3::Entities::LotteryActivityEntities::Order
          rescue RuntimeError => e
            present :error, 1
            present :detail, e.message
            present :avail_amount, order.kol.avail_amount
            present :avail_ticket, order.lottery_activity.avail_number
          end
        end
      end
    end
  end
end
