module Articles
  class ElasticClient
    Host = Rails.application.secrets[:elastic_server]
    cattr_accessor :client
    def self.client
      @@client = Elasticsearch::Client.new({host: Host, log: true})    if @@client.blank?
      @@client
    end

    def self.reset
      client.transport.reload_connections!
    end

    def self.get_text(read_list_ids =[])
      try_count = 0
      begin
        res = client.search index: 'article_all',
                            type: 'fulltext',
                            body: {
                              _source: ["text", "title", "biz_name"],
                              query: {
                                terms: { id: read_list_ids  },
                              }
                            }
        res['hits']['hits'].collect{|t| t["_source"]}
      rescue  Exception => e
        try_count += 1
        if try_count < 3
          reset
          retry
        else
          Rails.logger.elastic.info e.message
          return []
        end
      end
    end

    # , publish_date: {gte: Date.today - 1.days}
    def self.search(text, options = {})
      try_count = 0
      if !options[:select]   #根据收藏历史推荐
        filter = {
          bool: {
            must_not: {
              terms: { id: options[:push_list_ids]}
            }
          }
        }
        query = {
          multi_match: {
            query:  text,
            fields:  [ "text", "title"]
          }
        }
      else      # 选择喜欢文章
        filter = {}
        query = {
          bool: {
            filter: [
              { term: { chosen: 't'}},
              { range: { publish_date: { gte: Date.today - 1.days }}}
            ]
          }
        }
      end
      begin
        res = client.search index: 'article_7',
                            type: 'fulltext',
                            body: {
                              _source: ["id", "url", "msg_cdn_url", "title", "biz_name"],
                              query: query,
                              filter: filter,
                              from: 0,
                              size: options[:size] || 100
                            }
        sources = res['hits']['hits'].collect{|t| t["_source"]}
        sources
      rescue Exception => e
        try_count += 1
        if try_count < 3
          reset
          retry
        else
          Rails.logger.elastic.info e.backtrace
          return []
        end
      end
    end
  end
end


# curl -XPOST h4:9200/wx_biz/fulltext/_search -d '
# {
# "from": 0,
# "size": 5,
# "query" : {
# "query_string" : {
# "default_field" : "text",
# "query" : "母婴"
# }
# },
# "filter" : {
# "bool": {"must_not": {"terms" : { "id" : [ "78443398", "78400096" ]  }  }}
# }
# }'

# curl -XPOST 139.196.39.136:9200/wx_biz/fulltext/_search -d '
# {
# "from": 0,
# "size": 5,
# "query" : {
# "query_string" : {
# "default_field" : "text",
# "query" : "母婴"
# }
# }
# }'


# curl -XPOST 139.196.39.136:9200/article_7/fulltext/_search -d '
# {
#   "query": {
#     "bool": {
#        "filter": [
#         { "term":  { "chosen": "t" }}
#       ]
#     }
#   }
# }'
