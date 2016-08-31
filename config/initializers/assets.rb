# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.assets.precompile << lambda do |filename, path|
  path =~ /vendor\/assets/ && !%w(.js .css).include?(File.extname(filename))
end

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

Rails.application.config.assets.precompile += %w( landing.js landing.css
  email.css mail-template.css export_stories.css kol/kol_value.css admin.css admin.js mobile/application.css mobile/application.js)

Rails.application.config.assets.precompile += %w(
  website.css website.js  kol/*.js kol/*.css app/*.js app/*.css brand_v2.css brand_v2.js passport.*)

Rails.application.config.assets.precompile +=  %w(*.woff *.ttf *.svg *.eot)

Rails.application.config.assets.precompile += %w( cpses/app-webview-v2.css cpses/zepto.js cpses/common.js cpses/app-webview-v2.js cpses/jweixin-1.js cpses/wxUtil.js)
# react 部分 编译
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "webpack").to_s
Rails.application.config.assets.precompile += %w( brand-static.css brand-vendor-bundle-static.js brand-app-bundle-static.js server-bundle.js )
Rails.application.config.assets.precompile << Proc.new { |path| path.start_with?("brand-") }
NonStupidDigestAssets.whitelist += [/brand-/]
