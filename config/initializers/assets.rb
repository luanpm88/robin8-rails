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
  email.css mail-template.css export_stories.css)
Rails.application.config.assets.precompile += %w(
  website.css website.js  kol/*.js kol/*.css app/*.js app/*.css)

Rails.application.config.assets.precompile +=  %w(*.woff *.ttf *.svg *.eot)
# Add client/assets/ folders to asset pipeline's search path.
# If you do not want to move existing images and fonts from your Rails app
# you could also consider creating symlinks there that point to the original
# rails directories. In that case, you would not add these paths here.
Rails.application.config.assets.paths << Rails.root.join("client", "assets", "stylesheets")
Rails.application.config.assets.paths << Rails.root.join("client", "assets", "images")
Rails.application.config.assets.paths << Rails.root.join("client", "assets", "fonts")
Rails.application.config.assets.precompile += %w( generated/server-bundle.js )
