module IdentityAnalysis
  class FakeWeixinReport
    def self.primary_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"Robin8示例数据", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/d9ef6d2ef2.jpg",
                                         "user_name"=>"gh_ea8853a093df", "total_followers_count"=>402323, "new_followers_count"=>1723, "cancel_followers_count"=>121, "send_message_user_count"=>1223, "send_message_count"=>4232, "target_user_count"=>402323, "read_user_count"=>72323}}}
    end

    def self.messages_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"Robin8示例数据", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/1d5c7222f1.jpg", "user_name"=>"gh_ea8853a098df", "total_followers_count"=>0, "new_followers_count"=>0, "cancel_followers_count"=>0, "send_message_user_count"=>0, "send_message_count"=>0, "target_user_count"=>0, "read_user_count"=>0},
                                "messages"=>[
                                             {"report_time"=>"2016-05-09", "send_message_user_count"=>1630, "send_message_count"=>4333, "per_send_message_count"=>3},
                                             {"report_time"=>"2016-05-10", "send_message_user_count"=>1230, "send_message_count"=>5633, "per_send_message_count"=>4},
                                             {"report_time"=>"2016-05-11", "send_message_user_count"=>1420, "send_message_count"=>4315, "per_send_message_count"=>3},
                                             {"report_time"=>"2016-05-12", "send_message_user_count"=>1500, "send_message_count"=>4273, "per_send_message_count"=>3},
                                             {"report_time"=>"2016-05-13", "send_message_user_count"=>1730, "send_message_count"=>3722, "per_send_message_count"=>4},
                                             {"report_time"=>"2016-05-14", "send_message_user_count"=>1920, "send_message_count"=>4923, "per_send_message_count"=>3},
                                             {"report_time"=>"2016-05-15", "send_message_user_count"=>2030, "send_message_count"=>4733, "per_send_message_count"=>2},
                                             {"report_time"=>"2016-05-16", "send_message_user_count"=>2132, "send_message_count"=>3743, "per_send_message_count"=>2},
                                             {"report_time"=>"2016-05-17", "send_message_user_count"=>1821, "send_message_count"=>4323, "per_send_message_count"=>3},
                                             {"report_time"=>"2016-05-18", "send_message_user_count"=>1631, "send_message_count"=>4324, "per_send_message_count"=>4},
                                             {"report_time"=>"2016-05-19", "send_message_user_count"=>1834, "send_message_count"=>3425, "per_send_message_count"=>2},
                                             {"report_time"=>"2016-05-20", "send_message_user_count"=>1921, "send_message_count"=>4534, "per_send_message_count"=>3},
                                             {"report_time"=>"2016-05-21", "send_message_user_count"=>1234, "send_message_count"=>3674, "per_send_message_count"=>3},
                                             {"report_time"=>"2016-05-22", "send_message_user_count"=>1631, "send_message_count"=>5342, "per_send_message_count"=>3}
                                ]
      }}
    end

    def self.articles_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"Robin8示例数据", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/1d5c7222f1.jpg", "user_name"=>"gh_ea8853a098df", "total_followers_count"=>0, "new_followers_count"=>0, "cancel_followers_count"=>0, "send_message_user_count"=>0, "send_message_count"=>0, "target_user_count"=>0, "read_user_count"=>0},
                                "articles"=>[
                                  {"publish_date"=>"2016-05-09", "target_user_count"=>383786, "share_user_count"=>4988, "read_user_count"=>89323, "title" => '朝阳公园大事件!“跑男”要来?'},
                                  {"publish_date"=>"2016-05-10", "target_user_count"=>385433, "share_user_count"=>6733, "read_user_count"=>62323, "title" => '和男票一样高是种怎样的体验?'},
                                  {"publish_date"=>"2016-05-11", "target_user_count"=>386432, "share_user_count"=>8473, "read_user_count"=>72323, "title" => '你我相爱就是对孩子最好的富养'},
                                  {"publish_date"=>"2016-05-12", "target_user_count"=>387857, "share_user_count"=>4869, "read_user_count"=>68323, "title" => '这个国际大奖，史上第一次被中国人拿到了'},
                                  {"publish_date"=>"2016-05-13", "target_user_count"=>389327, "share_user_count"=>8777, "read_user_count"=>72323, "title" => '甘孜深藏了个无人的九寨沟，这里有关于“香格里...'},
                                  {"publish_date"=>"2016-05-14", "target_user_count"=>391067, "share_user_count"=>9877, "read_user_count"=>58823, "title" => '[健康]你身上有6块“长寿肌”，每天锻炼带来神...'},
                                  {"publish_date"=>"2016-05-15", "target_user_count"=>392186, "share_user_count"=>10983, "read_user_count"=>87623, "title" => '康熙停了半年，“失业少妇”小S有中年危机了吗?...'},
                                  {"publish_date"=>"2016-05-16", "target_user_count"=>393577, "share_user_count"=>4755, "read_user_count"=>72323, "title" => '世间最难忘的爱情，这7本书都写尽了'},
                                  {"publish_date"=>"2016-05-17", "target_user_count"=>394911, "share_user_count"=>7785, "read_user_count"=>76523, "title" => '救人反溺亡，我们该如何避免这样的悲剧?'},
                                  {"publish_date"=>"2016-05-18", "target_user_count"=>396764, "share_user_count"=>4633, "read_user_count"=>98776, "title" => '朝阳公园大事件!“跑男”要来?'},
                                  {"publish_date"=>"2016-05-19", "target_user_count"=>398446, "share_user_count"=>8967, "read_user_count"=>67887, "title" => '甘孜深藏了个无人的九寨沟，这里有关于“香格里...'},
                                  {"publish_date"=>"2016-05-20", "target_user_count"=>399547, "share_user_count"=>6895, "read_user_count"=>72323, "title" => '世间最难忘的爱情，这7本书都写尽了'},
                                  {"publish_date"=>"2016-05-21", "target_user_count"=>400621, "share_user_count"=>7866, "read_user_count"=>58823, "title" => '[健康]你身上有6块“长寿肌”，每天锻炼带来神...'},
                                  {"publish_date"=>"2016-05-22", "target_user_count"=>402323, "share_user_count"=>6783, "read_user_count"=>75523, "title" => '朝阳公园大事件!“跑男”要来?'}
                                ]
      }}

    end

    def self.user_analysises_data
      {"status"=>true, "data"=>{"user"=>{"email"=>"robin_tech@126.com", "nick_name"=>"Robin8示例数据", "logo_url"=>"http://7xozqe.com2.z0.glb.qiniucdn.com/uploads/weixin/user/logo/57453d4b830f785265906ad3/1d5c7222f1.jpg", "user_name"=>"gh_ea8853a098df", "total_followers_count"=>0, "new_followers_count"=>0, "cancel_followers_count"=>0, "send_message_user_count"=>0, "send_message_count"=>0, "target_user_count"=>0, "read_user_count"=>0},
                                "user_analysises"=>[
                                  {"report_time"=>"2016-05-09", "new_followers_count"=>1823, "growth_followers_count"=>1703, "cancel_followers_count"=>120, "total_followers_count" => '383786'},
                                  {"report_time"=>"2016-05-10", "new_followers_count"=>1723, "growth_followers_count"=>1647, "cancel_followers_count"=>76, "total_followers_count" => '385433'},
                                  {"report_time"=>"2016-05-11", "new_followers_count"=>1120, "growth_followers_count"=>999, "cancel_followers_count"=>121, "total_followers_count" => '386432'},
                                  {"report_time"=>"2016-05-12", "new_followers_count"=>1513, "growth_followers_count"=>1425, "cancel_followers_count"=>88, "total_followers_count" => '387857'},
                                  {"report_time"=>"2016-05-13", "new_followers_count"=>1563, "growth_followers_count"=>1470, "cancel_followers_count"=>93, "total_followers_count" => '389327'},
                                  {"report_time"=>"2016-05-14", "new_followers_count"=>1783, "growth_followers_count"=>1740, "cancel_followers_count"=>43, "total_followers_count" => '391067'},
                                  {"report_time"=>"2016-05-15", "new_followers_count"=>1233, "growth_followers_count"=>1119, "cancel_followers_count"=>114, "total_followers_count" => '392186'},
                                  {"report_time"=>"2016-05-16", "new_followers_count"=>1553, "growth_followers_count"=>1391, "cancel_followers_count"=>162, "total_followers_count" => '393577'},
                                  {"report_time"=>"2016-05-17", "new_followers_count"=>1773, "growth_followers_count"=>1334, "cancel_followers_count"=>139, "total_followers_count" => '394911'},
                                  {"report_time"=>"2016-05-18", "new_followers_count"=>1947, "growth_followers_count"=>1853, "cancel_followers_count"=>94, "total_followers_count" => '396764'},
                                  {"report_time"=>"2016-05-19", "new_followers_count"=>1764, "growth_followers_count"=>1682, "cancel_followers_count"=>82, "total_followers_count" => '398446'},
                                  {"report_time"=>"2016-05-20", "new_followers_count"=>1204, "growth_followers_count"=>1101, "cancel_followers_count"=>93, "total_followers_count" => '399547'},
                                  {"report_time"=>"2016-05-21", "new_followers_count"=>1174, "growth_followers_count"=>1074, "cancel_followers_count"=>110, "total_followers_count" => '400621'},
                                  {"report_time"=>"2016-05-22", "new_followers_count"=>1765, "growth_followers_count"=>1702, "cancel_followers_count"=>63, "total_followers_count" => '402323'}
                                ]
      }}
    end
  end
end
