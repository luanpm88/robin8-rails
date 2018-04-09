class ElasticArticlesController < ApplicationController
  skip_before_action  only: [:forward]

  def forward
    @res = ElasticArticleExtend.get_by_post_ids([params[:id]]).first

    Rails.logger.info "*" * 100
    Rails.logger.info @res['post_id']
    Rails.logger.info "*" * 100

    render text: 'not_found' unless @res
  end

end