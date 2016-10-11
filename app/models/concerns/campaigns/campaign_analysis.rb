module Campaigns
  module CampaignAnalysis
    extend ActiveSupport::Concern

    included do
      ExpectEffects = [{:name => 'incr_exposure', :label => "增加文章曝光", :budget_type => "click" },
                       {:name => 'incr_forward', :label => "增加文章转发", :budget_type => "post"},
                       {:name => 'incr_wechat_follower', :label => "增加公众号粉丝", :budget_type => "cpt"},
                       {:name => 'incr_download', :label => "增加APP下载量", :budget_type => "simple_cpi"},
                       {:name => 'input_questionnaire', :label => "填写问卷调查", :budget_type => "cpt"},
                       {:name => 'input_application', :label => "填写试用申请", :budget_type => "cpt"},
                       {:name => 'input_weibo_follower', :label => "增加微博粉丝", :budget_type => "cpt"},
                       {:name => 'complete_task', :label => "完成指定任务", :budget_type => "cpt"}]
      MinPerActionBudget = {:cpi => 2, :cpt => 1, :click => 0.2, :post => 2}
      MinBudget = 100
      CampaignDuration = 4.days
    end

    class_methods do
      #根据期望效果 设置活动类型
      def get_effect_budget_type(expect_effect)
        budget_type =  ExpectEffects.select{|t| return t[:budget_type] if t[:name] == expect_effect}
        budget_type ||= 'click'
        budget_type
      end

      #调用nlp api 获取分析结果
      NlpServer = "http://robin8-staging.cn:5000/kol/v1.0/analyze"
      def analyze_url(url)
        params = {url: url}
        res = RestClient.post NlpServer, params.to_json,  :content_type => :json, :accept => :json
        res = JSON.parse(res)["data"]  rescue nil
        res
      end

      #根据当时时间设置开始时间
      def get_start_time
        now = Time.now
        if now.hour >= 18
          return now.end_of_day + 10.hours
        else
          return now + 2.hours
        end
      end

      # 根据返回的结果获取城市名称
      def get_city_name(analysis_res)
        location = analysis_res["entities"]["locations"].keys.collect{|t| t[0..5].downcase }    rescue nil
        return nil if location.blank?
        cities = []
        location.each do |name_en|
          city_name = City.where("name_en like '#{name_en}%'").first.name     rescue nil
          if city_name
            cities << city_name
          else
            province = Province.where("name_en like '#{name_en}%'").first   rescue nil
            province.cities.collect{|t| cities << t.name }    if province
          end
        end
        cities.join(",")
      end

      #获取输入tab 内容,封装成campaign
      def get_campaign_input_info(url, analysis_res, expect_effect)
        per_budget_type = get_effect_budget_type(expect_effect)
        per_action_budget = MinPerActionBudget[per_budget_type.to_sym]
        start_time = get_start_time
        input_info = {name: analysis_res['article_title'], url: url, per_budget_type: per_budget_type, per_action_budget: per_action_budget, budget: MinBudget,
                      start_time: start_time, deadline: (start_time + CampaignDuration), img_url: analysis_res['article_image'], description: (analysis_res['article_text'][0..60]  rescue nil)  }
        campaign = Campaign.new(input_info)
        tags = analysis_res["industries"][0..5].collect{|t| t['label'] if t['probability'].to_i >= 3}.compact.join(",") rescue nil
        campaign.build_tag_target(target_type: 'tags', target_content: (tags.blank? ? "全部" : tags))
        cities = get_city_name(analysis_res)
        campaign.build_region_target(target_type: 'region', target_content: (cities.blank? ? "全部" : cities))
        #年龄\性别返回默认值 全部
        campaign.build_age_target(target_type: 'age', target_content: "全部")
        campaign.build_gender_target(target_type: 'gender', target_content: "全部")
        campaign
      end

      #获取分析tab 内容
      def get_analysis_info(analysis_res)
        info = {}
        info[:text] = analysis_res['article_text']
        keywords = []
        total_feq =  analysis_res["entities"]["features"].values.collect{|feature| feature['freq']}.sum    rescue 0
        analysis_res["entities"]["features"].values.each do |feature|
          keywords << {label: feature['expressions'].keys.first, probability: feature['freq'] / total_feq.to_f}
        end  rescue nil
        info[:keywords] =  keywords
        info[:sentiment] =  analysis_res['sentiment'].first.collect{|t| {:label => t['label'], :probability => t['probability'].round(2)}}
        persons_brands = []
        persons_brands_data = (analysis_res["entities"]['persons'].values rescue []) + (analysis_res["entities"]['brands'].values rescue [])
        persons_brands_data.each do |feature|
          persons_brands << {label: feature['expressions'].keys.first, freq: feature['freq']}
        end
        info[:persons_brands] = persons_brands
        products = []
        analysis_res["entities"]['producttypes'].values.each do |feature|
          products << {label: feature['expressions'].keys.first, freq: feature['freq']}
        end  rescue nil
        info[:products] = products
        info[:cities] =  analysis_res["entities"]["locations"].values.collect{|t| t["expressions"].keys.first}   rescue []
        info[:categories] = analysis_res["industries"].collect{|industry| {"label" => Tag::NameLabel[industry["label"]], "probability" => industry["probability"] } }
        info
      end

      # 返回所有的分析内容
      def get_analysis_res(url, expect_effect)
        analysis_res = analyze_url(url)
        campaign_input = get_campaign_input_info(url, analysis_res,expect_effect)
        analysis_info = get_analysis_info analysis_res
        [campaign_input, analysis_info]
      end
    end
  end
end

# url =  "http://cq.cqnews.net/html/2016-10/09/content_38875155.htm"
# analysis_res = Campaign.analyze_url(url)

