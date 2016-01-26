# config valid only for Capistrano 3.1
lock '3.4.0'
set :application, 'robin8'

# chinese developer shell execute :  echo "export china_instance='Y'" >> ~/.bash_profile
if ENV['china_instance'] == 'Y'
  set :repo_url, "git@code.robin8.net:andy/robin8.git"
else
  set :repo_url, "git@github.com:AYLIEN/robin8.git"
end

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
set :linked_files, %w{config/database.yml config/secrets.yml config/sidekiq.yml config/mongoid.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }

set :ssh_options, {:forward_agent => true}

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  task :upload_localization do
    on roles(:app)  do
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

  desc "Update the crontab file"
  task :update_crontab do
    on roles :app do
      within current_path do
        execute :bundle, :exec, "whenever --update-crontab #{fetch(:application)} --set environment=#{fetch(:rails_env)}"
      end
    end
  end

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     execute :touch, release_path.join('tmp/restart.txt')
  #   end
  # end

  #after :publishing, :restart
  after :publishing, :upload_localization
  after :publishing, :update_crontab
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
