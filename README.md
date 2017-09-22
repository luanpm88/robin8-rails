Robin8
======
Robin8 is next generation social and content marketing platform powered
by artificial intelligence.

# Development

  Steps to get development up and running

  * Install the following on your computer (use instructions from digitalocean.com if your dev is Linux)
    * MySQL 5.7
    * Redis 3.0.3
    * Ruby 2.2.0p0, (use a ruby version manager, like rbenv)
    * nodejs 6.11.2

  *  Clone the repository with git
  *  Run `bundle install`
    * if mysql gem install error then do `sudo apt-get install libmysqlclient-dev`
  *  Create a database inside mysql according to config/database.yml
  *  Get a `.sql` dump from one of the existing team member, and import that by
     `mysql -u root -p < dump.sql`
  *  `cd client` and then run `npm install`
  *  Go back to the app root directory and run `rake assets:webpack`
    * You should see errors such as:
      * ERROR in ./app/bundles/Robin8/components/shared/ReactEcharts.jsx
      * ERROR in ./app/bundles/Robin8/components/shared/echart/ChinaMap.js
    * Ignore them, they are node/react errors mostly in /brand
  * run `rails s` to have your server up!

With `mailcatcher` gem, you can debug mailer localy. It not in `Gemfile` for it will caused some problem.
If you want debug mailer localy, just simple run `gem install mailcatcher`, and fire up the server with `mailcatcher`:

```
$mailcatcher
Starting MailCatcher
==> smtp://127.0.0.1:1025
==> http://127.0.0.1:1080
```

### 2.0 新配置
* 加入 配置文件  juhe_key elastic_server  download_url    emay
* rake convert_to_utf8mb4
* notify/clean_cache


### 4-15
# rongyun
#  ocr:
   :root_path: /home/deployer/apps/screenshot_approve
    :logo_name: 'logo.png'
    :screenshot_name: 'screenshot_name.png'
# schedule auto cal influence
  cal_influence:
    :wday: 2
    :hour: 0
    :min:  5

# 5-31
    游客手机号： 13000000000  并且加入密码 123456
    nginx proxy_set_header  HTTP_X_FORWARDED_FOR $http_x_forwarded_for;
    init tasks
    init banner
    SpiderServer
    weixin secrets

#   recommend_server: '139.196.204.131'

#8.15
  rake database:cov....
  去除big_v scope
  1. 先导入k1,vs media .再导入 robin8 weibo public_wechat
  姓名含电话
  complete_info

