require 'elasticsearch'

Host = "139.196.39.136"
class MyElasticClient
  cattr_accessor :client
  def self.client
    @@client ||  Elasticsearch::Client.new({host: Host, log: true, ssl_verifypeer: false})
  end

  def self.reset
    client.transport.reload_connections!
    client.cluster.health
  end

  def self.search(field = 'text', field_value = '', from = 0 ,  size = 100)
    res = client.search index: 'wx_page2',
                        type: 'fulltext',
                        body: {
                          query: {
                            match: { text: 'Consulting  IssueShare  Chongqing  Beijing  Shanghai Shanghai Shanghai Shanghai  10月8日 10月8日 10月8日  2015年10月7日  10月9日  Company  LimitedLiabilityCompany  Friday  Bone  FacialExpression FacialExpression  Eye ' },
                          },
                          filter:{
                            bool: {
                              must_not: {
                                terms: {
                                  id: [ "78443398", "78400096","78165963" ]
                                }
                              }
                            }
                          },
                          from: 0,
                          size: 10
                        }
    res['hits']['hits']
  end

  def self.cache_articles(key, articles)

  end


end


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

