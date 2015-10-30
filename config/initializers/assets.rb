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
  email.css mail-template.css export_stories.css kol.css )
Rails.application.config.assets.precompile += %w( public_pages.js
  public_pages.css  website.css website.js export_stories.js kol.js kol/*.js)
