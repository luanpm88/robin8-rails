module IdentityAnalysis
  class FakeWeixinReport
    def self.primary_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"robin", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/d9ef6d2ef2.jpg",
                                         "user_name"=>"gh_ea8853a093df", "total_followers_count"=>2323, "new_followers_count"=>123, "cancel_followers_count"=>421, "send_message_user_count"=>1223, "send_message_count"=>232, "target_user_count"=>30, "read_user_count"=>342}}}
    end

    def self.messages_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"robin", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/1d5c7222f1.jpg", "user_name"=>"gh_ea8853a098df", "total_followers_count"=>0, "new_followers_count"=>0, "cancel_followers_count"=>0, "send_message_user_count"=>0, "send_message_count"=>0, "target_user_count"=>0, "read_user_count"=>0},
                                "messages"=>[
                                             {"report_time"=>"2016-05-09", "send_message_user_count"=>230, "send_message_count"=>3, "per_send_message_count"=>32},
                                             {"report_time"=>"2016-05-10", "send_message_user_count"=>230, "send_message_count"=>3, "per_send_message_count"=>30},
                                             {"report_time"=>"2016-05-11", "send_message_user_count"=>420, "send_message_count"=>5, "per_send_message_count"=>40},
                                             {"report_time"=>"2016-05-12", "send_message_user_count"=>230, "send_message_count"=>3, "per_send_message_count"=>23},
                                             {"report_time"=>"2016-05-13", "send_message_user_count"=>230, "send_message_count"=>2, "per_send_message_count"=>33},
                                             {"report_time"=>"2016-05-14", "send_message_user_count"=>320, "send_message_count"=>3, "per_send_message_count"=>23},
                                             {"report_time"=>"2016-05-15", "send_message_user_count"=>230, "send_message_count"=>3, "per_send_message_count"=>34},
                                             {"report_time"=>"2016-05-16", "send_message_user_count"=>232, "send_message_count"=>3, "per_send_message_count"=>32},
                                             {"report_time"=>"2016-05-17", "send_message_user_count"=>321, "send_message_count"=>3, "per_send_message_count"=>39},
                                             {"report_time"=>"2016-05-18", "send_message_user_count"=>231, "send_message_count"=>4, "per_send_message_count"=>34},
                                             {"report_time"=>"2016-05-19", "send_message_user_count"=>234, "send_message_count"=>5, "per_send_message_count"=>32},
                                             {"report_time"=>"2016-05-20", "send_message_user_count"=>321, "send_message_count"=>4, "per_send_message_count"=>23},
                                             {"report_time"=>"2016-05-21", "send_message_user_count"=>234, "send_message_count"=>4, "per_send_message_count"=>34},
                                             {"report_time"=>"2016-05-22", "send_message_user_count"=>231, "send_message_count"=>2, "per_send_message_count"=>53}
                                ]
      }}
    end

    def self.articles_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"robin", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/1d5c7222f1.jpg", "user_name"=>"gh_ea8853a098df", "total_followers_count"=>0, "new_followers_count"=>0, "cancel_followers_count"=>0, "send_message_user_count"=>0, "send_message_count"=>0, "target_user_count"=>0, "read_user_count"=>0},
                                "articles"=>[
                                  {"publish_date"=>"2016-05-09", "target_user_count"=>230, "share_user_count"=>3, "read_user_count"=>32, "title" => '朝阳公园大事件!“跑男”要来?'},
                                  {"publish_date"=>"2016-05-10", "target_user_count"=>230, "share_user_count"=>3, "read_user_count"=>30, "title" => '和男票一样高是种怎样的体验?'},
                                  {"publish_date"=>"2016-05-11", "target_user_count"=>420, "share_user_count"=>5, "read_user_count"=>40, "title" => '你我相爱就是对孩子最好的富养'},
                                  {"publish_date"=>"2016-05-12", "target_user_count"=>230, "share_user_count"=>3, "read_user_count"=>23, "title" => '这个国际大奖，史上第一次被中国人拿到了'},
                                  {"publish_date"=>"2016-05-13", "target_user_count"=>230, "share_user_count"=>2, "read_user_count"=>33, "title" => '甘孜深藏了个无人的九寨沟，这里有关于“香格里...'},
                                  {"publish_date"=>"2016-05-14", "target_user_count"=>320, "share_user_count"=>3, "read_user_count"=>23, "title" => '[健康]你身上有6块“长寿肌”，每天锻炼带来神...'},
                                  {"publish_date"=>"2016-05-15", "target_user_count"=>230, "share_user_count"=>3, "read_user_count"=>34, "title" => '康熙停了半年，“失业少妇”小S有中年危机了吗?...'},
                                  {"publish_date"=>"2016-05-16", "target_user_count"=>232, "share_user_count"=>3, "read_user_count"=>32, "title" => '世间最难忘的爱情，这7本书都写尽了'},
                                  {"publish_date"=>"2016-05-17", "target_user_count"=>321, "share_user_count"=>3, "read_user_count"=>39, "title" => '救人反溺亡，我们该如何避免这样的悲剧?'},
                                  {"publish_date"=>"2016-05-18", "target_user_count"=>231, "share_user_count"=>4, "read_user_count"=>34, "title" => '朝阳公园大事件!“跑男”要来?'},
                                  {"publish_date"=>"2016-05-19", "target_user_count"=>234, "share_user_count"=>5, "read_user_count"=>32, "title" => '甘孜深藏了个无人的九寨沟，这里有关于“香格里...'},
                                  {"publish_date"=>"2016-05-20", "target_user_count"=>321, "share_user_count"=>4, "read_user_count"=>23, "title" => '世间最难忘的爱情，这7本书都写尽了'},
                                  {"publish_date"=>"2016-05-21", "target_user_count"=>234, "share_user_count"=>4, "read_user_count"=>34, "title" => '[健康]你身上有6块“长寿肌”，每天锻炼带来神...'},
                                  {"publish_date"=>"2016-05-22", "target_user_count"=>231, "share_user_count"=>2, "read_user_count"=>53, "title" => '朝阳公园大事件!“跑男”要来?'}
                                ]
      }}

    end

    def self.user_analysises_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"robin", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/1d5c7222f1.jpg", "user_name"=>"gh_ea8853a098df", "total_followers_count"=>0, "new_followers_count"=>0, "cancel_followers_count"=>0, "send_message_user_count"=>0, "send_message_count"=>0, "target_user_count"=>0, "read_user_count"=>0},
                                "user_analysises"=>[
                                  {"report_time"=>"2016-05-09", "new_followers_count"=>230, "growth_followers_count"=>193, "cancel_followers_count"=>32, "total_followers_count" => '1001'},
                                  {"report_time"=>"2016-05-10", "new_followers_count"=>230, "growth_followers_count"=>203, "cancel_followers_count"=>30, "total_followers_count" => '1203'},
                                  {"report_time"=>"2016-05-11", "new_followers_count"=>420, "growth_followers_count"=>355, "cancel_followers_count"=>40, "total_followers_count" => '1550'},
                                  {"report_time"=>"2016-05-12", "new_followers_count"=>230, "growth_followers_count"=>213, "cancel_followers_count"=>23, "total_followers_count" => '1724'},
                                  {"report_time"=>"2016-05-13", "new_followers_count"=>230, "growth_followers_count"=>202, "cancel_followers_count"=>33, "total_followers_count" => '1900'},
                                  {"report_time"=>"2016-05-14", "new_followers_count"=>320, "growth_followers_count"=>310, "cancel_followers_count"=>23, "total_followers_count" => '2211'},
                                  {"report_time"=>"2016-05-15", "new_followers_count"=>230, "growth_followers_count"=>183, "cancel_followers_count"=>34, "total_followers_count" => '2550'},
                                  {"report_time"=>"2016-05-16", "new_followers_count"=>232, "growth_followers_count"=>190, "cancel_followers_count"=>32, "total_followers_count" => '2840'},
                                  {"report_time"=>"2016-05-17", "new_followers_count"=>321, "growth_followers_count"=>283, "cancel_followers_count"=>39, "total_followers_count" => '3041'},
                                  {"report_time"=>"2016-05-18", "new_followers_count"=>231, "growth_followers_count"=>284, "cancel_followers_count"=>34, "total_followers_count" => '3200'},
                                  {"report_time"=>"2016-05-19", "new_followers_count"=>234, "growth_followers_count"=>195, "cancel_followers_count"=>32, "total_followers_count" => '3390'},
                                  {"report_time"=>"2016-05-20", "new_followers_count"=>321, "growth_followers_count"=>294, "cancel_followers_count"=>23, "total_followers_count" => '3602'},
                                  {"report_time"=>"2016-05-21", "new_followers_count"=>234, "growth_followers_count"=>184, "cancel_followers_count"=>34, "total_followers_count" => '4007'},
                                  {"report_time"=>"2016-05-22", "new_followers_count"=>231, "growth_followers_count"=>162, "cancel_followers_count"=>53, "total_followers_count" => '4204'}
                                ]
      }}
    end
  end
end
