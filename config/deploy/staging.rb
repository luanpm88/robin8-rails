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

if ENV['china_instance'] == 'Y'
  server '139.196.36.27', user: 'deployer', roles: %w{web app db master}
  server '139.196.191.185', user: 'deployer', roles: %w{app slave}
  set :branch, 'deploy/master_cluster'
else

end

set :unicorn_env, "staging"
set :unicorn_rack_env, "staging"

set :stage, "staging"

set :rails_env, "staging"

set :rbenv_ruby, '2.2.0'

namespace :assets_chores do
  desc 'copy manifest.json from master to slave'
  task :copy_manifest_to_slave do
    on roles(:master) do
      execute "scp /home/deployer/apps/robin8/shared/public/assets/manifest.json deployer@139.196.191.185:/home/deployer/apps/robin8/shared/public/assets/manifest.json"
    end
  end
end
after 'deploy:compile_assets', 'assets_chores:copy_manifest_to_slave'

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
