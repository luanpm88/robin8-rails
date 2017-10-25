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
     new-feature-name branch into qa

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

  * qa branch will always have the latest features that is working
    * qa 是有我们app最新的功能，但还没上线
  * staging branch is the pre-release branch for us to test on production data
    * staging's data from the database is 24 hours behind our production
    * once pushed to bitbucket staging, you must deploy to staging (will be
      automated)
    * 一部署到staging 就得部署到staging 服务器里，（也将会自动化）
    * staging 是给Tina 或测试用的，there will be scripts to test on production
      data
  * master_cn branch is always the code for production
    * once pushed to bitbucket master_cn, you must deploy to production (will be
      automated)
    * 一部署到master cn 就得部署到服务器里，（这以后会自动化）
  * You can still use qa to test your own branch with
    `BRANCH_NAME=new-feature-name cap qa deploy` but do not merge your feature
    into QA in bitbucket until it has been reviewed

  [Read this on development and deployment process](http://dltj.org/article/software-development-practice/)

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


# QA Server and Production server

  Running rails console in server

  * ssh into the server, get access from current senior developers
  * cd into `/home/deployer/apps/robin8_qa/current`
  * run `RAILS_ENV=qa bundle exec rails console` and you're in
  * or `RAILS_ENV=production bundle exec rails console --sandbox` if this is production
  * NOTE! Always use `--sandbox` so it's read only on production
