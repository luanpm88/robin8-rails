class InfluenceIndustry < ActiveRecord::Base
  belongs_to :influence_metric

  validates_presence_of :industry_name, :industry_score, :avg_posts, :avg_comments, :avg_likes

  INDUSTRIES = ['airline', 'appliances', 'auto', 'babies', 'beauty', 'books', 'camera', 'ce',
                'digital', 'education', 'entertainment', 'fashion', 'finance', 'fitness', 'food',
                'furniture', 'games', 'health', 'hotel', 'internet', 'mobile', 'music', 'other',
                'realestate', 'sports', 'travel']

  def name_cn
    #INDUSTRIES_CN[self.industry_id]
  end

  def self.create_from_params industry
    InfluenceIndustry.create! industry_name: industry[:industry_name],
                industry_score: industry[:industry_score],
                avg_posts: industry[:avg_posts],
                avg_comments: industry[:avg_comments],
                avg_likes: industry[:avg_likes],
                influence_metric_id: industry[:influence_metric_id]

  end

  # def update_from_params industry
  #   self.update_attributes industry_name: industry[:name],
  #                          industry_score: industry[:industry_score],
  #                          avg_posts: industry[:avg_posts],
  #                          avg_comments: industry[:avg_comments],
  #                          avg_likes: industry[:avg_likes]
  #
  # end


end
