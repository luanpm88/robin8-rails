module Article
 class Store
   def self.get_list(kol_id)
     kol_article_stroe = "kol_articles_#{kol_id}"
     articles = Rails.cache.read(kol_article_stroe)  rescue []
     if articles.size < 10
       articles
     else

     end
   end

   def self.search_list(kol_id)
     kol_readed_ids = Rails.cache.read  "kol_readed_ids_#{kol_id}"
     kol_pushed_ids = Rails.cache.read "kol_pushed_ids_#{kol_id}"
     articles = ElasticClient.search(100,kol_readed_ids, kol_pushed_ids )
     Rails.cache.write("kol_articles_#{kol_id}", articles, :expired_in => 1.days)
   end

   def self.store_push_articles(articles)
     #1. 存储到mongodb
     articles  =


   end


   def self.reset_list()
     Rails.cache.delete_if {|k, v| k.stat_with? 'kol_articles_' }
   end
 end

end

