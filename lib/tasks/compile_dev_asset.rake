desc "compile assets for development "
task compile_dev_assets: :environment do
  generate_kol_js_dev_base
  generate_kol_css_dev_base
  compile_dev_file
end

