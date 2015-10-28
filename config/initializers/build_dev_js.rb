#TODO : 扩展到其他文件

KolPath = "#{Rails.root}/app/assets/javascripts/kol"
PublicPath = "#{Rails.root}/public/assets"
JsAsset = "dev_base"
JsAssetCompact = "dev_base_compact"

def generate_kol_dev_base
  kol_line_arr = File.read("#{KolPath}/application.js").split("\n")
  kol_reload_arr = File.read("#{KolPath}/dev_reload.js").split("\n")
  kol_other_content = kol_line_arr.map do |line|
    unless kol_reload_arr.include?(line)
      line
    end
  end.compact.join("\n")
  File.open("#{KolPath}/#{JsAsset}.js","w"){|f| f.write(kol_other_content)}
end

def compile_dev_file
  puts "--------start ---compile"
  system("rm #{PublicPath}/kol/#{JsAsset}**.js")
  Rake::Task['assets:clean'].invoke
  system("RAILS_ENV=development rake assets:precompile")
  # Rake::Task['assets:precompile'].invoke
  system("cp #{PublicPath}/kol/#{JsAsset}**.js #{PublicPath}/#{JsAssetCompact}.js")
  puts "--------end ---compile"
end

def monitor_reload_file
  listener = Listen.to("#{KolPath}") do |modified, added, removed|
    next if !modified.include?("#{KolPath}/dev_reload.js")
    puts "recompile generate dev base then compile it"
    generate_kol_dev_base
    compile_dev_file
  end
  listener.start
  puts "start monitor dev_reload.js"
end

if Rails.env == "development" and Robin8::Application.config.china_instance  && $0.include?("rails")  ## 避免 rake 启动
  require 'listen'
  require 'rake'
  Robin8::Application.load_tasks

  generate_kol_dev_base
  monitor_reload_file
end
