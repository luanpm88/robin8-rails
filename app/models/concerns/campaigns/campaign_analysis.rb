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
      def self.get_effect_budget_type(expect_effect)
        budget_type =  ExpectEffects.select{|t| return t[:budget_type] if t[:name] == expect_effect}
        budget_type ||= 'click'
        budget_type
      end

      #调用nlp api 获取分析结果
      def self.analyze_url(url)
        params = {url: url, text: text}
        res = RestClient.post Service12, params.to_json,  :content_type => :json, :accept => :json, :timeout => TimeOut
        res = JSON.parse(res)["data"]  rescue nil
        res
      end

      #根据当时时间设置开始时间
      def self.get_start_time
        now = Time.now
        if now.hour >= 18
          return now.end_of_day + 10.hours
        else
          return now + 2.hours
        end
      end

      # 返回所有的分析内容
      def self.get_analysis_res(url, expect_effect)
        per_budget_type = get_effect_budget_type(expect_effect)
        per_action_type = MinPerActionBudget[per_budget_type.to_sym]
        start_time = get_start_time
        analyze_res = analyze_url(url)
        input_info = {name: analyze_res['article_title'], url: url, per_budget_type: per_budget_type, per_action_type: per_action_type, budget: MinBudget,
                      start_time: start_time, deadline: (start_time + CampaignDuration), img_url: analyze_res['article_image'], desc: (analyze_res['article_text'][0..60]  rescue nil)  }
        campaign = Campaign.new(input_info)
        tags = res["industries"][0..5].collect{|t| t.label if t.probability.to_i >= 3}.join(",") rescue nil
        location = res["location"].keys.collect{|t| t.downcase }
        city_region = City.where(:name_en => )
      end
    end
  end
end
