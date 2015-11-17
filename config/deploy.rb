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

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/sidekiq.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }

set :ssh_options, {:forward_agent => true}

# Default value for keep_releases is 5
set :keep_releases, 5

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

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


  desc "Update the crontab file"
  task :update_crontab do
    on roles :app do
      within current_path do
        execute :bundle, "exec", "whenever",
          '--set', "environment=#{fetch(:rails_env)}",
          "--update-crontab", fetch(:application)
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
  after :publishing, 'unicorn:restart'
  after :publishing, :upload_localization

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
