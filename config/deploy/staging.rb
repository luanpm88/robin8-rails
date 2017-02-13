# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

#role :app, %w{deploy@example.com}
#role :web, %w{deploy@example.com}
#role :db,  %w{deploy@example.com}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

if $*.include? "new_qa"
  server '139.196.44.225', user: 'deployer', roles: %w{web app db master}
  set :branch, 'master_cn'
  set :server_name, '139.196.44.225'
else
  server '139.196.36.27', user: 'deployer', roles: %w{web app db master}
  set :branch, 'QA'
  set :server_name, 'test.robin8.net'
end

set :stage, "staging"
set :unicorn_env, "staging"
set :unicorn_rack_env, "staging"
set :rails_env, "staging"
set :rbenv_ruby, '2.2.0'
set :environment, 'staging'

namespace :assets_chores do
  desc 'copy manifest.json from master to slave'
  task :pull_manifest_from_master do
    master = roles(:app).find { |h| h.roles.include?(:master) }
    master_hostname = "#{master.user || 'root'}@#{master.hostname}"

    on roles(:slave) do
      execute "mkdir -p #{release_path}/public/assets/"
      execute "scp #{master_hostname}:/home/deployer/robin8_assets/assets/manifest.json #{release_path}/public/assets/manifest.json"
    end
  end
end

after 'deploy:sync_assets', 'assets_chores:pull_manifest_from_master'

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
