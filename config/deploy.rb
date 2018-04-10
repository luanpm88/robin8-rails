# coding: utf-8
# config valid only for Capistrano 3.1
lock '3.4.0'
set :application, 'robin8'
set :repo_url, "git@bitbucket.org:robin8/robin8.git"
# set :repo_url, "https://abel.guzman:123456qwerty@gitlab.service.chinanetcloud.com/backup/robin.git"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deployer/apps/robin8'

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

set :bundle_binstubs, nil
# Default value for :scm is :git
# set :scm, :git

set :slack_webhook, 'https://hooks.slack.com/services/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'
set :slack_username, -> { '千反田 える' }
set :slack_icon_url, -> { 'https://avatars3.githubusercontent.com/u/7478427?v=3&s=460' }
set :slack_msg_updating, -> { "#{fetch :slack_deploy_user} 正在部署 `#{fetch :branch}` 到 `#{fetch :stage}`" }
set :slack_msg_failed, -> { "#{fetch :slack_deploy_user} 部署 `#{fetch :branch}` 到 `#{fetch :stage}` 失败" }
set :slack_msg_updated, -> { "#{fetch :slack_deploy_user} 部署 `#{fetch :branch}` 到 `#{fetch :stage}` 成功" }

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml  config/redis.yml config/mongoid.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system client/node_modules}

# Default value for default_env is {}
set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH", :NODE_ENV => 'production'}

set :ssh_options, {:forward_agent => true}

# Default value for keep_releases is 5
set :keep_releases, 5

# Default value for whenever roles list
set :whenever_roles, %w{ master }

# Default value for sidekiq roles
set :sidekiq_role, %w{ master }

namespace :deploy do
  task :upload_localization do
    on roles(:db)  do
      within "#{current_path}" do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'localization:upload'
        end
      end
    end
  end

  task :convert_to_utf8mb4 do
    on roles(:db)  do
      within "#{current_path}" do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'database:convert_to_utf8mb4'
        end
      end
    end
  end

  task :import_regions do
    on roles(:db)  do
      within "#{current_path}" do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'china_regions:import'
        end
      end
    end
  end

  desc "Update the crontab file"
  task :update_crontab do
    on roles :master do
      within current_path do
        execute :bundle, :exec, "whenever --update-crontab #{fetch(:application)} --set environment=#{fetch(:rails_env)}"
      end
    end
  end

  desc "同步assets"
  task :sync_assets do
    on roles(:web) do
      within current_path do
        if $*[-1] == "noassets"
          with rails_env: fetch(:rails_env) do
            execute :'rake', "deploy_hanlder:sync_lastest_assets"
          end
        else
          with rails_env: fetch(:rails_env) do
            execute :'rake', "deploy_hanlder:backup_current_assets"
          end
        end
      end
    end
  end

  desc 'grant_permission check_unicorn.sh 文件为可执行'
  task :grant_permission do
    on roles(:app) do
      execute "cd #{current_path} && chmod a+x config/check_unicorn.sh"
    end
  end
  after :publishing, :grant_permission

  # after :publishing, :upload_localization
  after :publishing, :update_crontab
  after :publishing, :sync_assets
  after :publishing, 'unicorn:restart'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :'bin/rake', 'tmp:clear'
        end
      end
    end
  end
end

desc "noassets"
task :noassets do
  if $*.include? "noassets"
    puts '-'*80
    puts "本次部署采用noassets方式, 使用的是上一次部署的assets 文件, 请确保你没有修改assets 资源！！"
    puts '-'*80
  end
end


desc 'Invoke a rake command on the remote server'

# How to invoke with params:
# cap <stage> invoke['task:name_in_quotation_marks','option_1 option_2']
# notice spaces between options!
# In case when there's only single option just do
# cap <stage> invoke['task:name_in_quotation_marks','option_1']
task :invoke, [:command, :params] => 'deploy:set_rails_env' do |task, args|
  on primary(:app) do
    within current_path do
      with :rails_env => fetch(:rails_env) do
        if args[:params]
          params_string = "'" + args[:params].split(' ').join("','") + "'"
          rake "#{args[:command]}[#{params_string}]"
        else
          rake args[:command]
        end

      end
    end
  end
end
