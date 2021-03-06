# 此扩展应用是抓我们elasticsearch上的微博的原创(is_retweet: 0)数据
require 'typhoeus/adapters/faraday'

class ElasticArticleExtend

	cattr_accessor :client

  def self.client
    @@client = 	Elasticsearch::Client.new({hosts: Rails.application.secrets.elastic_search_host, log: false, transport_options: {headers: {'Content-Type' => 'application/json'}}})
  end

  def self.reset
    client.transport.reload_connections!
  end

  def self.get_new
  	res = client.search index: 'weibo_post_v4',
												body: {
													size: 1,
													sort: [{post_date: {order: 'desc'}}]
												}

    res['hits']['hits'].collect{|t| t["_source"]}[0]['post_id']
  end

	def self.get_by_tags(kol, post_id)
		tags = kol.tags.map(&:name).join(' OR ')
		tags = Tag.all.map(&:name).join(' OR ') if tags == ""

		_query = 	{
								bool: {
									must: [
										{
											range: {post_id: {lt: post_id}}
										},
										{
											query_string: {
												default_field: 'top_industry',
												query: tags
											}
										},
										{
											match: {is_retweet: 0}
										}
									]
								}
							}

		_sort = [
							{post_date: {order: 'desc'}},
							{shares: {order: 'desc'}}
						]
								
		res = client.search index: 'weibo_post_v4',
												body: {
													query: _query,
													sort: _sort
												}

    res['hits']['hits'].collect{|t| t["_source"]}
	end

	def self.get_by_hots(post_id)
		_query = 	{
								bool: {
									must: [
										{
											range: {post_id: {lt: post_id}}
										},
										{
											match: {is_retweet: 0}
										}
									]
								}
							}
		_sort = [
							{post_date: {order: 'desc'}},
							{shares: {order: 'desc'}}
						]

		res = client.search index: 'weibo_post_v4',
												body: {
													sort:  _sort,
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

	def self.recommend_by_tag(tag, post_id)
		_query = 	{
								bool: {
									must: [
										{
											range: {post_id: {lt: post_id}}
										},
										{
											query_string: {
												default_field: 'top_industry',
												query: tag
											}
										},
										{
											match: {is_retweet: 0}
										}
									]
								}
							}

		_sort = [
							{post_date: {order: 'desc'}},
							{comments:  {order: 'desc'}}	
						]
								
		res = client.search index: 'weibo_post_v4',
												body: {
													query: _query,
													size: 3,
													sort: _sort
												}

    res['hits']['hits'].collect{|t| t["_source"]}
	end

end