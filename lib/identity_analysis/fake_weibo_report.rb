module IdentityAnalysis
  class FakeWeiboReport
    Days = 30

    def self.primary_data
      {"status" => true, "data" => {
        "user" => {"uid" => 1340795527, "active" => true},
        "overview" => {"incremental_follower_number" => 1223, "decremental_follower_number" => 176, "verified_follower_ratio" => 0.33, "unverified_follower_ratio" => 0.67, "friend_number" => 234, "follower_number" => 4654343, "bilateral_number" => 87, "statuses_number" => 328}
      }}
    end

    def self.follower_follow_data
      decremental_followers = []
      incremental_followers = []
      today = Date.today
      sum_followers = 0
      (Days.downto(0)).to_a.each do |i|
        date = today - i.days
        incremental_count = 10 + rand(10)
        decremental_count = rand(4)
        sum_followers += incremental_count
        sum_followers -= decremental_count
        decremental_followers << {"r_date" => date, 'number' => decremental_count}
        incremental_followers << {"r_date" => date, 'number' => incremental_count}
      end
      decremental_follower_list = [{"name" => "希思立康商贸有限公司", "follower_number" => 8822, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.22.0.725.725.50/dfe4a088jw8f3usu1uju8j20ks0k8aaw.jpg"},
                                   {"name" => "chengzxli", "follower_number" => 1412, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.273.39.689.689.50/954f20edgw1f2a489nnm7j20sg0lc0xj.jpg"},
                                   {"name" => "净果--馨怡", "follower_number" => 141, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva1.sinaimg.cn/crop.79.0.264.264.50/006pYzIIgw1f23hnys5u7j30c90c8ta1.jpg"},
                                   {"name" => "开窗见悬崖", "follower_number" => 35, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva3.sinaimg.cn/default/images/default_avatar_female_50.gif"},
                                   {"name" => "希思立康商贸有限公司", "follower_number" => 8822, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.22.0.725.725.50/dfe4a088jw8f3usu1uju8j20ks0k8aaw.jpg"},
                                   {"name" => "chengzxli", "follower_number" => 1412, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.273.39.689.689.50/954f20edgw1f2a489nnm7j20sg0lc0xj.jpg"},
                                   {"name" => "净果--馨怡", "follower_number" => 141, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva1.sinaimg.cn/crop.79.0.264.264.50/006pYzIIgw1f23hnys5u7j30c90c8ta1.jpg"},
                                   {"name" => "开窗见悬崖", "follower_number" => 35, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva3.sinaimg.cn/default/images/default_avatar_female_50.gif"},
                                   {"name" => "希思立康商贸有限公司", "follower_number" => 8822, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.22.0.725.725.50/dfe4a088jw8f3usu1uju8j20ks0k8aaw.jpg"},
                                   {"name" => "chengzxli", "follower_number" => 1412, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.273.39.689.689.50/954f20edgw1f2a489nnm7j20sg0lc0xj.jpg"},
                                   {"name" => "净果--馨怡", "follower_number" => 141, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva1.sinaimg.cn/crop.79.0.264.264.50/006pYzIIgw1f23hnys5u7j30c90c8ta1.jpg"},
                                   {"name" => "开窗见悬崖", "follower_number" => 35, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva3.sinaimg.cn/default/images/default_avatar_female_50.gif"},
                                   {"name" => "希思立康商贸有限公司", "follower_number" => 8822, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.22.0.725.725.50/dfe4a088jw8f3usu1uju8j20ks0k8aaw.jpg"},
                                   {"name" => "希思立康商贸有限公司", "follower_number" => 8822, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.22.0.725.725.50/dfe4a088jw8f3usu1uju8j20ks0k8aaw.jpg"},
                                   {"name" => "净果--馨怡", "follower_number" => 141, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva1.sinaimg.cn/crop.79.0.264.264.50/006pYzIIgw1f23hnys5u7j30c90c8ta1.jpg"},
                                   {"name" => "开窗见悬崖", "follower_number" => 35, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva3.sinaimg.cn/default/images/default_avatar_female_50.gif"},
                                   {"name" => "希思立康商贸有限公司", "follower_number" => 8822, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva4.sinaimg.cn/crop.22.0.725.725.50/dfe4a088jw8f3usu1uju8j20ks0k8aaw.jpg"},
                                   {"name" => "净果--馨怡", "follower_number" => 141, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva1.sinaimg.cn/crop.79.0.264.264.50/006pYzIIgw1f23hnys5u7j30c90c8ta1.jpg"},
                                   {"name" => "开窗见悬崖", "follower_number" => 35, "unfollowed_at" => "2016-05-24", "profile_image_url" => "http://tva3.sinaimg.cn/default/images/default_avatar_female_50.gif"}]
      return [sum_followers, (sum_followers / Days), incremental_followers, decremental_followers, decremental_follower_list]
    end

    def self.follower_verified_data
      {"status" => true, "data" => {"user" => {"uid" => 1340795527, "active" => true},
                                    "sorted_followers" => [{"general_number" => 3118409, "verified_number" => 977412, "expert_number" => 558521, "general_ratio" => 0.67, "verified_ratio" => 0.21, "expert_ratio" => 0.12}]}}
    end

    def self.friend_verified_data
      unverified_number = 155200
      verified_number = 11040
      sorted_friends = []
      today = Date.today
      (Days.downto(0)).to_a.each do |i|
        date = today - i.days
        unverified_number = unverified_number + 250 + rand(100)
        verified_number = verified_number + rand(30)
        sorted_friends << {"r_date" => date, 'total_number' => unverified_number + verified_number, "verified_number" => verified_number, "unverified_number" => unverified_number}
      end
      {"status" => true, "data" => {"user" => {"uid" => 1340795527, "active" => true},
                                    "bilateral_friendships" => [{"follower_number" => 4654343, "bilateral_number" => 120807, "friend_number" =>  unverified_number + verified_number}],
                                    "sorted_friends" => sorted_friends
      }}
    end

    def self.follower_profile_data
      {"status" => true, "data" => {"user" => {"uid" => 1340795527, "active" => true},
                                    "regional_followers" => [{ "regions" => [{"name" => "北京", "code" => "11", "location" => "北京 海淀区", "number" => 24564, "ratio" => 0.065}, {"name" => "上海", "code" => "31", "location" => "上海 黄浦区", "number" => 43534, "ratio" => 0.134}, {"name" => "重庆", "code" => "50", "location" => "重庆 南岸区", "number" => 32112, "ratio" => 0.033}, {"name" => "广西", "code" => "45", "location" => "广西 桂林", "number" => 2111, "ratio" => 0.033}, {"name" => "安徽", "code" => "34", "location" => "安徽 六安", "number" => 23222, "ratio" => 0.033}, {"name" => "福建", "code" => "35", "location" => "福建 福州", "number" => 33463, "ratio" => 0.033}, {"name" => "山东", "code" => "37", "location" => "山东 聊城", "number" => 12354, "ratio" => 0.033}, {"name" => "Other", "code" => "100", "location" => "Other", "number" => 12342, "ratio" => 0.1}, {"name" => "河北", "code" => "13", "location" => "河北 唐山", "number" => 12323, "ratio" => 0.033}, {"name" => "湖北", "code" => "42", "location" => "湖北 武汉", "number" => 23244, "ratio" => 0.033}, {"name" => "陕西", "code" => "61", "location" => "陕西 渭南", "number" => 3411, "ratio" => 0.133}, {"name" => "浙江", "code" => "33", "location" => "浙江 温州", "number" => 32334, "ratio" => 0.133}, {"name" => "广东", "code" => "44", "location" => "广东 深圳", "number" => 11233, "ratio" => 0.133}, {"name" => "江苏", "code" => "32", "location" => "江苏 淮安", "number" => 12324, "ratio" => 0.033}, {"name" => "北京", "code" => "11", "location" => "北京 海淀区", "number" => 13445, "ratio" => 0.1}, {"name" => "上海", "code" => "31", "location" => "上海 黄浦区", "number" => 12333, "ratio" => 0.133}, {"name" => "重庆", "code" => "50", "location" => "重庆 南岸区", "number" => 2433, "ratio" => 0.033}, {"name" => "广西", "code" => "45", "location" => "广西 桂林", "number" => 17764, "ratio" => 0.033}, {"name" => "安徽", "code" => "34", "location" => "安徽 六安", "number" => 16645, "ratio" => 0.033},
                                                                            {"name" => "河北", "code" => "13", "location" => "河北 唐山", "number" => 1, "ratio" => 0.033}]}],
                                    "sexual_followers" => [{ "male_number" => 15, "female_number" => 15, "male_ratio" => 0.5, "female_ratio" => 0.5}]}}
    end

    def self.statuses_data
      {"status" => true, "data" => {"user" => {"uid" => 1340795527, "active" => true},
                                    "statuses" => [{"r_id" => 3977975534071148, "publised_at" => "2016-05-22T16:45:37.000+08:00", "text" => "keep running", "isLongText" => false, "reposts_count" => 5332, "comments_count" =>15666, "attitudes_count" => 54332, "user" => {"name" => "ACATW", "profile_image_url" => "http://tva2.sinaimg.cn/crop.0.0.1024.1024.50/4feaea87jw8eqaue48rucj20sg0sgk6s.jpg"}},
                                                   {"r_id" => 3977252163665874, "publised_at" => "2016-05-20T16:51:12.000+08:00", "text" => "http://t.cn/RqsjFt0", "isLongText" => false, "reposts_count" =>3726, "comments_count" => 1244, "attitudes_count" => 78766, "user" => {"name" => "ACATW", "profile_image_url" => "http://tva2.sinaimg.cn/crop.0.0.1024.1024.50/4feaea87jw8eqaue48rucj20sg0sgk6s.jpg"}},
                                                   {"r_id" => 3972456891339628, "publised_at" => "2016-05-07T11:16:30.000+08:00", "text" => "上线啦上线啦，大家可以去体验了。ACATW-对讲机", "isLongText" => false, "reposts_count" => 2736, "comments_count" => 16674, "attitudes_count" => 87554, "user" => {"name" => "ACATW", "profile_image_url" => "http://tva2.sinaimg.cn/crop.0.0.1024.1024.50/4feaea87jw8eqaue48rucj20sg0sgk6s.jpg"}},
                                                   {"r_id" => 3969206997116052, "publised_at" => "2016-04-28T12:02:34.000+08:00", "text" => "ACATW正在研发一款新APP 给大家预告一下", "isLongText" => false, "reposts_count" => 6635, "comments_count" => 15435, "attitudes_count" => 64332, "user" => {"name" => "ACATW", "profile_image_url" => "http://tva2.sinaimg.cn/crop.0.0.1024.1024.50/4feaea87jw8eqaue48rucj20sg0sgk6s.jpg"}},
                                                   {"r_id" => 3961324331801254, "publised_at" => "2016-04-06T17:59:41.000+08:00", "text" => "人活着就是为了小时候吹过的牛逼. http://t.cn/RqbwFJz", "isLongText" => false, "reposts_count" => 6487, "comments_count" => 13224, "attitudes_count" => 56773, "user" => {"name" => "ACATW", "profile_image_url" => "http://tva2.sinaimg.cn/crop.0.0.1024.1024.50/4feaea87jw8eqaue48rucj20sg0sgk6s.jpg"}}
                                    ]}}
    end

  end
end
