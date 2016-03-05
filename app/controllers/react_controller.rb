class ReactController < ApplicationController
  layout 'brand'

  def index
  end

  # fake campaigns
  def campaigns
    # 加一个延时，模拟获取数据耗时
    sleep(2)

    render json: {
      success: true,
      campaigns: [
        {
          name: '吉姆雷诺带你飞',
          start_time: Time.zone.now.to_i * 1000,
          description: '你好！打得不错！我选择死亡！',
          url: "https://runup.tech",
          cost: 321,
          currency: '$',
          participators_count: 382,
          ctr: '28.7%',
          remaining_days: 2
        }
      ] * 10
    }
  end
end