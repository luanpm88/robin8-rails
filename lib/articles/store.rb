module Articles
 class Store
   def self.get_list(kol_id, per_page = 10)
     #1. 找出
     selected_articles = search_list(kol_id, per_page)
     #2. 对即将返回的数据 存储
     PushArticle.kol_add_push_articles(kol_id, selected_articles)
     selected_articles
   end

   def self.search_list(kol_id, per_page)
     #1. 优先从缓存读取
     articles = Rails.cache.read("kol_articles_#{kol_id}")  rescue []
     #2. 缓存没有需要去检索
     if articles.nil? || articles.size == 0
       kol_read_ids = ArticleAction.get_action_ids(kol_id, 'read')
       kol_like_ids = ArticleAction.get_action_ids(kol_id, 'like')
       kol_forward_ids = ArticleAction.get_action_ids(kol_id, 'forward')
       kol_collect_ids = ArticleAction.get_action_ids(kol_id, 'collect')
       kol_push_ids = PushArticle.get_push_ids(kol_id)
       articles = ElasticClient.search(per_page * 10, kol_read_ids, kol_push_ids )
     end
     #3. 取出，并把剩下的缓存住
     selected_articles = articles.shift(per_page)
     Rails.cache.write("kol_articles_#{kol_id}", articles, :expires_in => 1.days)
     #4. 返回取出的文章
     selected_articles
   end

   def self.reset_kol_articles(kol_id)
     Rails.cache.write("kol_articles_#{kol_id}", nil)
   end

   def self.reset_all_list
     Rails.cache.delete_matched('kol_articles_*')
     Rails.cache.delete_matched('kol_push_ids_*')
   end
 end

end

