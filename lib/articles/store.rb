module Articles
 class Store
   def self.get_list(kol_id, per_page = 10)
     #1. 找出
     selected_articles = search_list(kol_id, per_page)
     #2. 对即将推送的文章的数据进行 存储
     PushArticle.kol_add_push_articles(kol_id, selected_articles)
     selected_articles
   end

   def self.search_list(kol_id, per_page)
     #1. 优先从缓存读取
     articles = Rails.cache.read("kol_articles_#{kol_id}")  rescue []
     #2. 缓存没有需要去检索
     if articles.nil? || articles.size == 0
       kol_push_ids = PushArticle.get_push_ids(kol_id)
       #2.1  检索时 需要先根据阅读文章取文章关键字
       text = get_read_article_text(kol_id)
       #2.2  把文章关键字 去查询
       articles = ElasticClient.search(text, kol_push_ids, per_page * 10, )
       Rails.logger.elastic.info "=======search_list===articles:#{articles.collect{|t| t.id}}"
     end
     #3. 取出，并把剩下的缓存住
     selected_articles = articles.shift(per_page)
     Rails.cache.write("kol_articles_#{kol_id}", articles, :expires_in => 1.days)
     #4. 返回取出的文章
     Rails.logger.elastic.info "=======selected_articles===selected_articles:#{articles.collect{|t| t.id}}"
     selected_articles
   end

   def self.get_read_article_text(kol_id)
     kol_read_ids = ArticleAction.get_action_ids(kol_id, 'read')
     # kol_like_ids = ArticleAction.get_action_ids(kol_id, 'like')
     # kol_forward_ids = ArticleAction.get_action_ids(kol_id, 'forward')
     # kol_collect_ids = ArticleAction.get_action_ids(kol_id, 'collect')
     Rails.logger.elastic.info "=======get_read_article_text===kol_id:#{kol_id}====kol_read_ids:#{kol_read_ids}"
     if kol_read_ids.size > 0
       articles = ElasticClient.search(kol_read_ids)
       text = articles.collect{|article| article['text'] + article["title"] + article["biz_info"]}.join(" ")
       Rails.logger.elastic.info "=======get_read_article_text===text:#{text[0..100]}"
       text
     else
       " "
     end
   end

   def self.reset_kol_articles(kol_id)
     Rails.logger.elastic.info "=======reset_kol_articles===kol_id:#{kol_id}"
     Rails.cache.write("kol_articles_#{kol_id}", nil)
   end

   def self.reset_all_list
     Rails.cache.delete_matched('kol_articles_*')
     Rails.cache.delete_matched('kol_push_ids_*')
   end
 end

end

