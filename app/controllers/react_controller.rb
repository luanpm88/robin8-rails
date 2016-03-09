class ReactController < ApplicationController
  layout 'brand'

  skip_before_action :verify_authenticity_token

  def index
  end

  # fake campaigns
  def campaigns

    # return render json: {campaigns: [], error: 'error'}, status: 301

    # 加一个延时，模拟获取数据耗时
    sleep(1)

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

  def create_campaigns
    sleep(2);

    render json: {
      success: [true, false].sample,
      error: '错误信息',
      model: {
        name: '创建的',
        start_time: Time.zone.now.to_i * 1000,
        description: '你好！打得不错！我选择死亡！',
        url: "https://runup.tech",
        cost: 321,
        currency: '$',
        participators_count: 382,
        ctr: '28.7%',
        remaining_days: 2
      }
    }
  end
end