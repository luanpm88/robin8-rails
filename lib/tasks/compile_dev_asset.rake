desc "compile assets for development "
task compile_dev_assets: :environment do
  system("rm -rf #{Rails.root}/tmp/cache")
  generate_dev_base
  compile_dev_assets
end

