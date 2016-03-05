class ReactController < ApplicationController
  layout 'brand'

  def index
  end

  # fake campaigns
  def campaigns
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
      ]
    }
  end
end