# 此扩展应用是抓我们elasticsearch上的微博数据，以及微信文章
require 'typhoeus/adapters/faraday'

class ElasticArticleExtend

	cattr_accessor :client

	Host = '47.100.60.3:56671'

  def self.client
    @@client = 	Elasticsearch::Client.new({
    							hosts: Host, 
    							log: true,
    							transport_options: {headers: {'Content-Type' => 'application/json'}}
    						})
  end

  def self.reset
    client.transport.reload_connections!
  end

	def self.get_by_tags(kol, post_date)
		tags = kol.tags.map(&:name).join(' OR ')
		tags = Tag.all.map(&:name).join(' OR ') unless tags

		_query = 	{
								bool: {
									must: [
										{
											range: {post_date: {lt: post_date}}
										},
										{
											query_string: {
												default_field: 'top_industry',
												query: tags
											}
										}
									]
								}
							}
								
		res = client.search index: 'weibo_post_v4',
												body: {
													query: _query
												}

    res['hits']['hits'].collect{|t| t["_source"]}
	end

	def self.get_by_post_ids(ids=[])
		_query = 	{
                terms: {post_id: ids},
							}
								
		res = client.search index: 'weibo_post_v4',
												body: {
													query: _query
												}

    res['hits']['hits'].collect{|t| t["_source"]}
	end

end