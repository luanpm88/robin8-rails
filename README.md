Robin8
======
Robin8 is next generation social and content marketing platform powered
by artificial intelligence.

# Notes

  Please refer to these documentation for some parts of the app

  * [Influence score API](https://robin8.atlassian.net/wiki/spaces/APP/pages/74743823/Influence+score+API)
  * [Invitation mechanics](https://robin8.atlassian.net/wiki/spaces/APP/pages/54853633/Invitation+mechanics)
  * [Settling Process](https://robin8.atlassian.net/wiki/spaces/APP/pages/51347525/Technical+notes)
  * [ruby-style-guide](https://github.com/season/ruby-style-guide/blob/master/README-zhCN.md)
  * [ruby-style-guide-extra](#ruby-style-guide-extra)

# Development and Deployment Process 开发和部署流程

  When building a new feature
  开发新功能的流程：

  1. `git checkout qa` branch and pull the latest from bitbucket by
     `git pull --rebase origin qa:qa`
  2. `git checkout -b new-feature-name`
  3. When you have completed your feature, create a pull-request from your
     new-feature-name branch to qa.
    完成你这个分支的开发后，请创建一个你的分支到qa的pull-request
  4. You must find someone else to review your code, assign it to them on bitbucket.Someone else from the team must review your code and merge the
     new-feature-name branch into qa.
    创建pull-request时，你必须指定其他人来检查你的代码。其他人检查你的代码，认为没有问题之后，就可以把你的分支合并到qa。

  When deploying a new feature
  部署新分支的流程：

  * Merge `qa` into `staging`, deploy to staging.robin8.net
  * Tina (and some automated tests) run tests on staging.robin8.net
  * Merge `staging` into `master_cn`, deploy to robin8.net
  * During emergencies, just merge `qa` to `staging` then to `master_cn` and
    deploy immediately
    如果需求很紧急，可以把qa分支合并到staging分支后，接着把staging分支合并到master_cn,然后立即部署到production。
  * Try not to deploy before 6pm, if things go wrong, everyone will not go
     home
  * Try not to deploy on Fridays, if things go wrong, no more weekends
  * Next phase is to automate the deployment process

  Notes on the three main branches

  * `qa` branch will always have the latest features that is working
    * qa分支的代码将总是有我们app最新的功能，但还没上线
    * anything in `qa` will be deployed at the next deployment, only put code
      that is ready to be released
    * 只要是合并到qa分支的代码，就是准备要上线的
  * `staging` branch is the pre-release branch for us to test on production data
    * staging分支是预发布分支，staging服务器的数据库和production是一致的
    * staging server's data from the database is 24 hours behind our production
    * staging服务器的数据比production落后24小时
    * once pushed to bitbucket staging, you must deploy to staging (will be
      automated)
    * 只要是合并到staging分支的代码，就要部署到staging 服务器里，（也将会自动化）
    * staging 是给Tina 或测试用的，there will be scripts to test on production
      data
  * `master_cn` branch is always the code for production
    * once pushed to bitbucket master_cn, you must deploy to production (will be
      automated)
    * 只要是合并到master_cn的代码，就要部署到服务器里，（这以后会自动化）
  * You can still use qa to test your own branch with
    `BRANCH_NAME=new-feature-name cap qa deploy` but do not merge your feature
    into QA in bitbucket until it has been reviewed
    你还是可以用`BRANCH_NAME=new-feature-name cap qa deploy`来部署你的分支到qa环境做测试，但在你pull-request并被别人检查通过之后，你才能把你的分支合并到qa
  * If you haven't modified anything on images、JS、stylesheets in app/assets, you can use `BRANCH_NAME=new-feature-name cap qa deploy noassets` to deploy your branch to QA, and this can save some time.
    如果你的的分支没有对app/assets的images、JS、stylesheets等做任何修改，那就可以使用`BRANCH_NAME=new-feature-name cap qa deploy noassets`来部署到QA，这可以节省部署时间。
  * [Read this on development and deployment process](http://dltj.org/article/software-development-practice/)

  Style-Guide

  * Commit messages should explain both the "what", "why" of code changes
  * 你的commit中应该说明修改了什么，为什么要做修改。
    * The first line must provide a summary of the changes
    * 第一句话要对你做的修改做个总结性陈述。
    * add more paragraph if necessary
    * 如果有必要，就在后面做更详细的说明。
  * use `=begin` and `=end` to comment your code to preserve git commit history
  * 如果要注释掉某些代码，请用`=begin` 和 `=end` ，这样可以保证commit历史不被覆盖，就可以找到每行代码是谁写的。
    * allows the use of git blame as comments

  * [Why commit messages are important](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)

# Development Environment

  Steps to get development up and running

  * Install the following on your computer (use instructions from digitalocean.com if your dev is Linux)
    * MySQL 5.7
    * Redis 3.0.3
    * Ruby 2.2.0p0, (use a ruby version manager, like rbenv)
    * nodejs 6.11.2

  *  Clone the repository with git
  *  Run `bundle install`
    * if mysql gem install error then do `sudo apt-get install libmysqlclient-dev`
    * 如果mysql的gem安装出错，执行 `sudo apt-get install libmysqlclient-dev`命令
  *  Create a database inside mysql according to config/database.yml
  *  根据config/database.yml文件来创建一个mysql的数据库
  *  Get a `.sql` dump from one of the existing team member, and import that by
     `mysql -u root -p < dump.sql`
     从team member那里拿`.sql` 文件，用`mysql -u root -p < dump.sql`命令导入到你刚刚新建的数据库中
  *  `cd client` and then run `npm install`
  *  Go back to the app root directory and run `rake assets:webpack`
  * 回到robin8的根目录，执行`rake assets:webpack`
    * You should see errors such as:
      * ERROR in ./app/bundles/Robin8/components/shared/ReactEcharts.jsx
      * ERROR in ./app/bundles/Robin8/components/shared/echart/ChinaMap.js
    * Ignore them, they are node/react errors mostly in /brand
    * 他们都是在访问/brand相关页面时才会出错，因为brand相关页面是用react开发的。如果你不负责brand相关页面的开发，不用管他们。
  * run `rails s` to have your server up!
  * for the ability to develop React on `/brand/` you must use this command to
    start your local development server `foreman start -f Procfile.hot`
    如果你负责开发`/brand/`相关页面，要用到react.js,那就必须用 `foreman start -f Procfile.hot`命令来启动你本地的服务器

# Running tests 自动化测试

  To run tests

  * run `rake db:test:prepare` to dump the schema into your test environment
    database, 这个命令会把数据库的schema 导入本地测试环境里
  * run `spring rspec` to run the tests, 这会开启本地测试
  * for individual tests, eg. run `spring rspec
    spec/api/prop_api/influence_metric_spec.rb`,执行特定部分的自动测试


# QA, Staging, Production server

  Important

  * robin8.net root path is powered by an nginx reverse proxy to another server
    under the repository
    [kol_search_engine_without_react](https://bitbucket.org/robin8/kol_search_engine_without_react_v1.2.1)
  * robin8.net首页（搜索引擎）是用了nginx reverse proxy 去到了另一个项目
  * you can look at the nginx sample configuration in
    `config/nginx_production.conf`
    speficially the `location = / {` which uses proxy_pass to another server
  * 你在nginx 的设置文件可以看到 `location = / {` 首页是去了另一个服务器
  * everytime you deploy be sure to check that the unicorn master process is
    killed and renewed, you can run eg `cap production sidekiq:stop` then
    `cap production sidekiq:start` then `ps aux | grep "unicorn master"`

  Logs

  * `/home/deployer/apps/robin8_qa/current/log`, `robin8_staging` or `robin8`
  * qa、staging和production的日志文件都在current/log中。
  * For each log file, eg `kol_pk.log`, search on the codebase for
    `Rails.logger.kol_pk` and you will see where it's called
    对于log文件夹中的每一个文件，例如kol_pk.log文件，你在项目代码中搜索`Rails.logger.kol_pk`，就可以看到是哪个地方调用了这个方法，从而产生了日志。

  Running rails console in server

  * ssh into the server, get access from current senior developers
  * cd into `/home/deployer/apps/robin8_qa/current` or `robin8_staging` or
    `robin8`
  * run `RAILS_ENV=qa bundle exec rails console` or `RAILS_ENV=staging`
  * or `RAILS_ENV=production bundle exec rails console --sandbox` if this is production
  * NOTE! Always use `--sandbox` so it's read only on production
  * 如果在production环境，一定要加`--sandbox`参数，这样才会是只读模式，不会对production的数据做出改动。

  Database dumps

  * production database dumps are available at staging.robin8.net server at
    `/home/deployer/apps/robin8_staging/shared/tmp/prod.tar.gz`
  * staging服务器中的`/home/deployer/apps/robin8_staging/shared/tmp/prod.tar.gz`文件，就是production的数据
    * this dump is refreshed every night at 00:01 am 这份数据每晚00：01会更新一次
    * to download and import to your local database 可以用以下命令把这个数据库导入到你本地的数据库中
      * `scp deployer@staging.robin8.net:/home/deployer/apps/robin8_staging/shared/tmp/prod.tar.gz
        ~/path/to/your/directory`请把/your/directory替换成你的电脑上你想要下载到的目录
      * `tar -cvzf ~/path/to/your/directory/prod.tar.gz`
      * `mysql -u username -ppassword database-name < prod.sql`, look for your
        username and password for development at `config/database.yml`
  * to import the database to qa server, run `cap staging invoke['db:import_to_qa']`
    on your local machine or run `RAILS_ENV=staging rake db:import_to_qa`
  * 做本地执行`cap staging invoke['db:import_to_qa']`或`RAILS_ENV=staging rake db:import_to_qa`命令，即可将staging的数据库导入qa

  ##ruby-style-guide-extra

  Here ....
