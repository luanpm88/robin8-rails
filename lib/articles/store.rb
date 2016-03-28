module Articles
 class Store
   #发现文章列表
   DefaultSize = 20
   MaxSize = 100
   PerPage = 10
   def self.get_discovery_list(kol_id, title = nil, page = 1)
     Rails.logger.elastic.info "=======get_discovery_list===kol_id:#{kol_id}====title:#{title}"
     selected_articles = search_list(kol_id, title, {:page => page})
     #2. 对自动推荐的文章的数据进行存储 ,检索不需要
     PushArticle.kol_add_push_articles(kol_id, selected_articles)      if title.blank?
     selected_articles
   end

   #选择喜爱文章 列表
   def self.get_select_like_list(kol_id, title = nil)
     selected_articles = search_list(kol_id, title, {:select => true})
     selected_articles
   end

   def self.search_list(kol_id, title, options = {})
     #1. 优先从缓存读取
     articles = Rails.cache.read("kol_articles_#{kol_id}_#{title}")  rescue []
     #2. 缓存没有需要去检索
     if (articles.nil? || articles.size == 0)
       if options[:select]    #选择喜爱文章
         articles = ElasticClient.search(title, options.merge!({:select => true, :size => MaxSize}))
         articles.sample(MaxSize)
       elsif title.present?   #搜索文章
         Rails.logger.elastic.info "=======search discovery===kol_id:#{kol_id}====title:#{title}"
         articles = ElasticClient.search(title, options.merge!({:size => DefaultSize, :from => (options[:page] - 1) * PerPage }))
       else
         #2.1  检索时 需要先根据阅读文章取文章关键字
         text = get_relation_article_text(kol_id)
         if text
           #2.2  把文章关键字 去查询
           articles = ElasticClient.search(text, {:push_list_ids => PushArticle.get_push_ids(kol_id), :size => DefaultSize})
         else
           articles = ElasticClient.search(text, {:select => true, :size => DefaultSize})
         end
       end
     end
     #3. 取出，并把剩下的缓存住
     selected_articles = articles.shift(PerPage)
     Rails.cache.write("kol_articles_#{kol_id}_#{title}", articles, :expires_in => 1.days)
     #4. 返回取出的文章
     Rails.logger.elastic.info "=======search_list===selected_articles:#{selected_articles.collect{|t| t['id']}}"
     selected_articles
   end

   def self.get_relation_article_text(kol_id)
     relation_ids = ArticleAction.get_relation_ids(kol_id)
     Rails.logger.elastic.info "=======get_read_article_text===kol_id:#{kol_id}====relation_ids:#{relation_ids}"
     if relation_ids.size > 0
       order_artciles = []
       articles = ElasticClient.get_text(relation_ids)
       relation_ids.each{|id| order_artciles += articles.select{|t| t["id"] == "#{id}"} }
       text_arr = order_artciles.collect{|article| "#{article['text']} #{article['title'].gsub(article['biz_name'],'')}".split(/\s+/)}.flatten
       Rails.logger.elastic.info "--------get_read_article_text---text:#{text_arr.join(" ")[0,100]}"
       return text_arr.join(" ")[0,1000]
     end
     return nil
   end

   def self.reset_kol_articles(kol_id)
     Rails.logger.elastic.info "=======reset_kol_articles===kol_id:#{kol_id}"
     Rails.cache.delete_matched("kol_articles_#{kol_id}_*")
   end

   def self.reset_all_list
     Rails.cache.delete_matched('kol_articles_*')
     Rails.cache.delete_matched('kol_push_ids_*')
   end

   # def self.test(kol_read_ids)
   #   kol_read_ids = kol_read_ids.split(",") if kol_read_ids.class == String
   #   articles = ElasticClient.get_text(kol_read_ids)
   #   text = articles.collect{|article| "#{article['text']} #{article['title'] } #{article['title_orig']}"}.join(" ")
   #   puts text
   #   articles = ElasticClient.search("Photo   Price 2月28日  Platform Platform   Investment  Investment  Investment  Investment  Investment  Investment  Investment  Investment  Investment   Sale   Landing     StanfordUniversity  ResearchCenter", kol_read_ids)
   #   puts articles
   # end
 end

end

