module Articles
  class ElasticClient
    Host = Rails.application.secrets[:elastic_server]
    cattr_accessor :client
    def self.client
      @@client ||  Elasticsearch::Client.new({host: Host, log: true, ssl_verifypeer: false})
    end

    def self.reset
      client.transport.reload_connections!
    end

    def self.get_text(read_list_ids =[])
      try_count = 0
      begin
        res = client.search index: 'wx_biz',
                            type: 'fulltext',
                            body: {
                              _source: ["text", "title",  "biz_name"],
                              query: {
                                match: { id: read_list_ids  },
                              }
                            }
        res = res['hits']['hits']
        res.collect{|t| t["_source"]}
      rescue  e
        try_count += 1
        if try_count < 3
          reset
          retry
        else
          Rails.logger.elastic.info e.message
        end
      end
    end

    #TODO add log
    def self.search(text, push_list_ids = [], size = 100)
      try_count = 0
      begin
        res = client.search index: 'wx_biz',
                            type: 'fulltext',
                            body: {
                              _source: ["id", "url", "msg_cdn_url", "title_orig", "biz_name"],
                              query: {
                                multi_match: {
                                  query:  text,
                                  fields: [ "text", "title", "biz_info" ]
                                }
                              },
                              filter:{
                                bool: {
                                  must_not: {
                                    terms: {
                                      id: push_list_ids
                                    }
                                  }
                                }
                              },
                              from: 0,
                              size: size
                            }
        res = res['hits']['hits']
        res.collect{|t| t['_source']}
      rescue  e
        try_count += 1
        if try_count < 3
          reset
          retry
        else
          Rails.logger.elastic.info e.message
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
# "query" : "Consulting  IssueShare  Chongqing  Beijing  Shanghai Shanghai Shanghai Shanghai  10月8日 10月8日 10月8日  2015年10月7日  10月9日  Company  LimitedLiabilityCompany  Friday  Bone  FacialExpression FacialExpression  Eye "
# }
# },
# "filter" : {
# "bool": {"must_not": {"terms" : { "id" : [ "78443398", "78400096" ]  }  }}
# }
# }'

# curl -XPOST 139.196.39.136:9200/wx_page2/fulltext/_search -d '
# {
# "from": 0,
# "size": 5,
# "query" : {
# "query_string" : {
# "default_field" : "text",
# "query" : "Consulting  IssueShare  Chongqing  Beijing  Shanghai Shanghai Shanghai Shanghai  10月8日 10月8日 10月8日  2015年10月7日  10月9日  Company  LimitedLiabilityCompany  Friday  Bone  FacialExpression FacialExpression  Eye "
# }
# },
# "filter" : {
# "bool": {"must_not": {"terms" : { "id" : [ "78443398", "78400096","78165963","78327314","78238955" ,"78186008" ]  }  }}
# }
# }'
