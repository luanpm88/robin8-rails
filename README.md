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
* 加入phone_location influence sidekiq queue
* 加入 配置文件  juhe_key elastic_server  download_url    emay
* rake database:

