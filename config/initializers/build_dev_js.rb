#TODO : 扩展到其他文件

KolJsPath = "#{Rails.root}/app/assets/javascripts/kol"
KolCssPath = "#{Rails.root}/app/assets/stylesheets/kol"
PublicPath = "#{Rails.root}/public/assets"
Asset = "dev_base"
AssetCompact = "dev_base_compact"

def generate_kol_js_dev_base
  kol_line_arr = File.read("#{KolJsPath}/application.js").split("\n")
  kol_reload_arr = File.read("#{KolJsPath}/dev_reload.js").split("\n")
  kol_other_content = kol_line_arr.map do |line|
    unless kol_reload_arr.include?(line) && line.start_with?("//=")
      line
    end
  end.compact.join("\n")
  File.open("#{KolJsPath}/#{Asset}.js","w"){|f| f.write(kol_other_content)}
end

def generate_kol_css_dev_base
  kol_line_arr = File.read("#{KolCssPath}/application.scss").split("\n")
  kol_reload_arr = File.read("#{KolCssPath}/dev_reload.scss").split("\n")
  kol_other_content = kol_line_arr.map do |line|
    unless kol_reload_arr.include?(line) && line.start_with?("*=")
      line
    end
  end.compact.join("\n")
  File.open("#{KolCssPath}/#{Asset}.scss","w"){|f| f.write(kol_other_content)}
end

def compile_dev_file
  puts "--------start ---compile"
  system("rm #{PublicPath}/kol/#{Asset}**.js")
  system("rm #{PublicPath}/kol/#{Asset}**.css")
  Rake::Task['assets:clean'].invoke
  system("RAILS_ENV=development rake assets:precompile")
  # Rake::Task['assets:precompile'].invoke
  system("cp #{PublicPath}/kol/#{Asset}**.js #{PublicPath}/#{AssetCompact}.js")
  system("cp #{PublicPath}/kol/#{Asset}**.css #{PublicPath}/#{AssetCompact}.css")
  puts "--------end ---compile"
end

def monitor_reload_file
  listener = Listen.to(KolJsPath,KolCssPath) do |modified, added, removed|
    next if !modified[0].include?("dev_reload")
    puts "recompile generate dev base then compile it"
    generate_kol_js_dev_base
    generate_kol_css_dev_base
    compile_dev_file
  end
  listener.start
  puts "start monitor dev_reload"
end

if Rails.env == "development" and Robin8::Application.config.china_instance  && $0.include?("rails")  ## 避免 rake 启动
  require 'listen'
  require 'rake'
  Robin8::Application.load_tasks

  generate_kol_js_dev_base
  generate_kol_css_dev_base
  monitor_reload_file
end
