PublicPath = "#{Rails.root}/public/assets"
Asset = "dev_base"
AssetCompact = "dev_base_compact"
AssetMoudles = %w{kol app}

# 获取某个asset 模块 目录路径
def get_compile_path(asset_module, asset_type = 'js')
  if asset_type == 'js'
    "#{Rails.root}/app/assets/javascripts/#{asset_module}"
  else
    "#{Rails.root}/app/assets/stylesheets/#{asset_module}"
  end
end


def generate_js_dev_base(asset_module)
  asset_module_path = get_compile_path(asset_module, 'js')
  full_arr = File.read("#{asset_module_path}/application.js").split("\n")
  reload_arr = File.read("#{asset_module_path}/dev_reload.js").split("\n")
  other_content = full_arr.map do |line|
    unless reload_arr.include?(line) && line.start_with?("//=")
      line
    end
  end.compact.join("\n")
  File.open("#{asset_module_path}/#{Asset}.js","w"){|f| f.write(other_content)}
end

def generate_css_dev_base(asset_module)
  asset_module_path = get_compile_path(asset_module, 'css')
  full_arr = File.read("#{asset_module_path}/application.scss").split("\n")
  reload_arr = File.read("#{asset_module_path}/dev_reload.scss").split("\n")
  other_content = full_arr.map do |line|
    unless reload_arr.include?(line) && line.start_with?("*=")
      line
    end
  end.compact.join("\n")
  File.open("#{asset_module_path}/#{Asset}.scss","w"){|f| f.write(other_content)}
end

def generate_dev_base
  AssetMoudles.each do |m|
    generate_js_dev_base(m)
    generate_css_dev_base(m)
  end
end

def delete_origin_file
  AssetMoudles.each do |m|
    system("rm #{PublicPath}/#{m}/#{Asset}**.js")
    system("rm #{PublicPath}/#{m}/#{Asset}**.css")
  end
end

def copy_compact_file
  AssetMoudles.each do |m|
    system("cp #{PublicPath}/#{m}/#{Asset}**.js #{PublicPath}/#{m}/#{AssetCompact}.js")
    system("cp #{PublicPath}/#{m}/#{Asset}**.css #{PublicPath}/#{m}/#{AssetCompact}.css")
  end
end


# start here
def compile_dev_assets
  puts "--------start ---compile"
  delete_origin_file
  Rake::Task['assets:clean'].invoke
  system("RAILS_ENV=development rake assets:precompile")
  # Rake::Task['assets:precompile'].invoke
  copy_compact_file
  puts "--------end ---compile"
end
