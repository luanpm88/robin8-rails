Robin8
======
Robin8 is next generation social and content marketing platform powered
by artificial intelligence.

# Development and Deployment Process

  When building a new feature

  1. `git checkout qa` branch and pull the latest from bitbucket by
     `git pull --rebase origin qa:qa`
  2. `git checkout -b new-feature-name`
  3. When you have completed your feature, create a pull-request from your
     new-feature-name branch to qa
  4. Someone else from the team must review your code and merge the
     new-feature-name branch into qa, you must find someone else to review
     your code, assign it to them on bitbucket

  When deploying a new feature

  * Merge `qa` into `staging`, deploy to staging.robin8.net
  * Tina (and some automated tests) run tests on staging.robin8.net
  * Merge `staging` into `master_cn`, deploy to robin8.net
  * During emergencies, just merge `qa` to `staging` then to `master_cn` and
    deploy immediately
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
    * staging's data from the database is 24 hours behind our production
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
  * If you haven't modified anything on images、JS、stylesheets in app/assets, you can use `BRANCH_NAME=new-feature-name cap qa deploy noassets` to deploy your branch to QA, and this can save some time.
    如果你的的分支没有对app/assets的images、JS、stylesheets等做任何修改，那就可以使用`BRANCH_NAME=new-feature-name cap qa deploy noassets`来部署到QA，这可以节省部署时间。
  * [Read this on development and deployment process](http://dltj.org/article/software-development-practice/)

  Style-Guide

  * Commit messages should explain both the "what", "why" of code changes
    * The first line must provide a summary of the changes
    * add more paragraph if necessary
  * use `=begin` and `=end` to comment your code to preserve git commit history
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
  * or you can try `foreman start -f Procfile.hot`

# Running tests 自动化测试

  To run tests

  * run `rake db:test:prepare` to dump the schema into your test environment
    database, 这命令会把数据库的schema 导入本地测试环境里
  * run `spring rspec` to run the tests, 这会开启本地测试
  * for individual tests, eg. run `spring rspec
    spec/api/prop_api/influence_metric_spec.rb`,执行特定部分的自动测试


# QA, Staging, Production server

  Logs
  * `/home/deployer/apps/robin8_qa/current/log`, `robin8_staging` or `robin8`
  * For each log file, eg `kol_pk.log`, search on the codebase for
    `Rails.logger.kol_pk` and you will see where it's called

  Running rails console in server

  * ssh into the server, get access from current senior developers
  * cd into `/home/deployer/apps/robin8_qa/current` or `robin8_staging` or
    `robin8`
  * run `RAILS_ENV=qa bundle exec rails console` or `RAILS_ENV=staging`
  * or `RAILS_ENV=production bundle exec rails console --sandbox` if this is production
  * NOTE! Always use `--sandbox` so it's read only on production

  Database dumps

  * production database dumps are available at staging.robin8.net server at
    `/home/deployer/apps/robin8_staging/tmp/prod.tar.gz`
    * this dump is refreshed every night at 12:01 am
    * to download and import to your local database
      * `scp deployer@staging.robin8.net:/home/deployer/apps/robin8_staging/current/tmp/prod.tar.gz
        ~/you-own-directory`
      * `tar -cvzf ~/you-own-directory/prod.tar.gz`
      * `mysql -u username -ppassword database-name < prod.sql`, look for your
        username and password for development at `config/database.yml`
