class CnRecommendationsController < ApplicationController
  def index
    render :json => [{:images => ["http://img4.cache.netease.com/cnews/2015/11/20/20151120061500334c3_550.jpg"],
                     :title => "just test", 
                     :author_name => "andy",
                     :timeago => "one year ago", :shares_count => 111, :recommendationType => "test",
                     :link => "111",
                     :description => "description",
                     :blog_name => "blog_name",
                     :characters_count => 1,
                     :words_count => 1,
                     :paragraphs_count => 1,
                     :adverbs_count => 1,
                     :adjectives_count => 1,
                     :nouns_count => 1,
                     :places_count => 1,
                     :people_count => 1,
                     :organizations_count => 1,
                     :topics => ["test"],
                     :iptc_categories => ["111"],
                     :reposts_count => 1,
                     :comments_count => 2,
                     :likes_count => 22,
                     :shares_count => 22,
                     :published_at => "2015-10-10",
                     :email => "andy@qq.com",
                     :reference => "test",
                     :recommendationType => "CONTENT"
                     }]*10
  end
end