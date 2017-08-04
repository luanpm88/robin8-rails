namespace :unicorn do
  desc '# Task to restart unicorn. Primarily to used from cronjob'
  task :restart => :environment do
    project_path = Dir.pwd
    pid_file = File.join(project_path, "tmp", "pids", "unicorn.pid")
    pid = File.read(pid_file).gsub("\n", '')
    Rails.logger.info "--- Restarting unicorn server (probably from cronjob) ---"
    Rails.logger.info "========== Pid file: #{pid_file}"
    Rails.logger.info "========== PID to kill: #{pid}"
    Rails.logger.info "---------------------------------------------------------"

    `kill -s USR2 #{pid}`
  end
end
