module Concerns
  module CampaignTest
    extend ActiveSupport::Concern
    included do
    end

    class_methods do
      Pre = "http://7xozqe.com2.z0.glb.qiniucdn.com/"
      def get_img_url2
        order = rand(21)
        "#{Pre}test#{order}.jpg"
      end

      TestCampaigns = [
        {:name => "原七大军区善后办任务披露",
         :desc => "这注定是一个载入军史的春天，这必将是一个开新图强的起点：随着习主席和中央军委一声令下，七大军区完成历史使命，五大战区正式组建亮相。",
         :url => "http://mil.sina.cn/zgjq/2016-02-23/detail-ifxprucu3128168.d.html?from=wap"
        },
        {:name => "商务部部长：中国中高收入阶层正在形成",
         :desc => "商务部部长高虎城今天（2月23日）上午在国务院新闻办举行的发布会上表示，中国中高收入阶层正在形成，这个阶层的消费不满足于大众化的需求。因此，商务工作从供给侧发力的一个重点，就是如何满足中高收入阶层个性化、差异化的消费需求，满足他们对品种更多、质量更好、更为安全、购物环境更为舒适的需求",
         :url => "http://news.sina.com.cn/o/2016-02-23/doc-ifxprupc9814419.shtml"
        },
        {:name => "12省份计生新政出台 产假最长180天最短128天",
         :desc => "为全面实施两孩政策，各地相继开始修订地方计生条例，目前，天津、浙江、宁夏等12省份的新计生条例已经出台。经人民网编辑梳理发现，不同省份产 假从最长的180天到最短的128天，可相差近两个月之多。而对于百姓担心的两孩生育相关保障问题，多名专家围绕产儿科和幼儿园建设这两大育儿重点给出建 议，其中，来自北京市第一幼儿园的冯慧燕建议恢复“托儿所”，为全面二胎作保障",
         :url => "http://news.sina.com.cn/c/nd/2016-02-23/doc-ifxprucs6406466.shtml"
        },
        {:name => "村民家中水井打出汽油 加进车里动力十足(图)",
         :desc => "2月1日，西安市临潼区斜口街办代张杨村两户村民从自家水井里打出汽油，经记者实测，加上该油的摩托车、小轿车竟然动力十足。村民在啧啧称奇的同时也不禁对自己的饮用水安全产生了担心。",
         :url => "http://news.sina.com.cn/s/wh/2016-02-23/doc-ifxprucs6417923.shtml"
        },

        {:name => "库克再发备忘录:呼吁司法部撤回破解iPhone裁决",
         :desc => "北京时间2月22日晚间消息，据美国新闻聚合网站BuzzFeed报道，苹果公司(以下简称“苹果”)CEO蒂姆·库克(Tim Cook)周一再次致信员工，呼吁美国司法部撤回法庭之前做出的“要求苹果帮助美国联邦调查局(以下简称“FBI”)解锁iPhone”的裁",
         :url => "http://tech.sina.com.cn/t/2016-02-22/doc-ifxprucu3117549.shtml"
        },
        {:name => "直连大脑的机器手，韧带肌腱一应俱全",
         :desc => "研究人员近日研发出了一款新型机器手，这是目前最接近真实人手的产品，可以模拟出我们双手的一举一动。",
         :url => "http://blog.jobbole.com/97974/"
        },
        {:name => "程序媛往往比程序猿更受认可",
         :desc => "用一句话总结这项最新的学术研究的结论就是，女程序员的代码往往写得比男性更好，而且人们也都知道这一点。",
         :url => "http://blog.jobbole.com/97931/"
        },
        {:name => "刘慈欣谈引力波：未来长期对人类生活无意义",
         :desc => "“在相当长一段时间，引力波将停留在基础科学研究的层面，用来扩展人类知识，加深对宇宙的理解。但对人类的现实生活，我不认为有任何意义。”中国科幻作家刘慈欣23日在接受中新社记者采访时说。",
         :url => "http://tech.sina.com.cn/d/i/2016-02-23/doc-ifxprucs6417664.shtml"
        },

        {:name => "日内瓦车展亮相 Rimac电动超级跑车官图",
         :desc => "日前，来自克罗地亚的超级跑车品牌Rimac发布了旗下电动超级跑车Rimac Concept One的量产版官图，新车将会在今年3月的日内瓦车展首发亮相。",
         :url => "http://auto.sina.com.cn/newcar/h/2016-02-23/detail-ifxprucs6419749.shtml"
        },
        {:name => "回溯时间:引力波能让我们窥见宇宙创生时刻吗？",
         :desc => "爱因斯坦再一次被证明是正确的：正如他在100年前所言，引力场发生的变化的确会像波纹一般在时空之海中泛起涟漪并向外传播。",
         :url => "http://tech.sina.com.cn/d/i/2016-02-23/doc-ifxprucu3124046.shtml"
        },
        {:name => "夕阳照片现“火瀑布”奇观 似熔岩绝壁流泻而下",
         :desc => "一道艳丽夺目的“熔岩”由绝壁流泻而下，形成绝美风景，这便是大自然的杰作――“火瀑布”(Firefall)。",
         :url => "http://slide.tech.sina.com.cn/d/slide_5_453_67295.html"
        },
        {:name => "日媒指责中国渔船在日本专属经济区“爆渔”",
         :desc => "日媒指责中国渔船在日本专属经济区“爆渔”",
         :url => "http://news.sina.com.cn/c/2016-02-23/doc-ifxprupc9824473.shtml"
        },
      ]

      def add_test_data(per_budget_type = nil, long = nil)
        if !Rails.env.production?
          u = User.find 84
          per_budget_type = ['post', 'click'].sample    if per_budget_type.blank?
          campaign_attrs = TestCampaigns[rand(12)]
          long = rand(2) == 1                            if long.nil?
          campaign = Campaign.create(:status => 'unexecute', :user => u, :budget => (long ? 40 : 3), :per_action_budget => 1, :start_time => Time.now + 2.seconds, :deadline => Time.now + (long ? 24.hours : 1.hours),
                                     :url => campaign_attrs[:url], :name => campaign_attrs[:name], :description => campaign_attrs[:desc], :img_url => get_img_url2, :per_budget_type => per_budget_type)
          campaign.status = 'agreed'
          campaign.save
        end
      end

      def add_recruit_data(long = false, region = "上海市,北京市", influence_score = '500')
        if !Rails.env.production?
          u = User.find 79
          campaign_attrs = TestCampaigns[rand(12)]
          campaign = Campaign.new(:user => u, :budget => (long ? 40 : 3), :per_action_budget => 1, :recruit_start_time => Time.now + 2.seconds, :recruit_end_time => Time.now + 15.minutes, :start_time =>  Time.now + 20.minutes, :deadline => Time.now + (long ? 24.hours : 5.minutes),
                                  :url => campaign_attrs[:url], :name => campaign_attrs[:name], :description => campaign_attrs[:desc], :img_url => get_img_url, :per_budget_type => 'recruit', :address => '上海市 静安区 xxx路', :task_description => '先去现场，然后拍照转发到朋友圈')
          campaign.save
          puts campaign.id
          CampaignTarget.create(:target_type => 'region', :target_content => region, :campaign_id => campaign.id)
          CampaignTarget.create(:target_type => 'influence_score', :target_content => influence_score, :campaign_id => campaign.id)
          campaign.status = 'agreed'
          campaign.save
        end
      end

      def check(campaign_id)
        kol_ids = CampaignApply.where(:campaign_id => campaign_id).collect{|t| t.kol_id }
        CampaignApply.platform_pass_kols(campaign_id,kol_ids)
        CampaignApply.brand_pass_kols(campaign_id,kol_ids)
      end
    end
  end
end
