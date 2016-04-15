desc "Database related tasks(remember : update database connect encoding)"
namespace :deploy_hanlder do
  desc "同步上一次的assets 文件"
  task sync_lastest_assets: :environment do
    system("cp -rf  /home/deployer/robin8_assets/assets #{Dir.pwd}/public/")
  end

  desc "备份这一次的assets 文件, 便于下一次部署使用"
  task backup_current_assets: :environment do
    system("rm -rf /home/deployer/robin8_assets")
    system("mkdir -p /home/deployer/robin8_assets")
    system("cp -rf /home/deployer/apps/robin8/current/public/assets /home/deployer/robin8_assets/")
  end  
end