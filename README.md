Robin8
======
Robin8 is next generation social and content marketing platform powered
by artificial intelligence.

# Development

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
