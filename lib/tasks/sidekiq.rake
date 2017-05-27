namespace :schedule do
  task :sidekiq_restart do
    sh "bundle exec sidekiqctl stop tmp/pids/sidekiq.pid"
    sh "bundle exec sidekiq -d -L log/sidekiq.log -C config/sidekiq.yml"
  end
end


