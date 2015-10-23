if Rails.env == "development" and Robin8::Application.config.china_instance
  require 'listen'
  require 'rake'
  Robin8::Application.load_tasks # <-- MISSING LINE

  listener = Listen.to('app/assets/javascripts') do |modified, added, removed|
    puts "begin compile js"
    begin_time = Time.now
    #%x[RAILS_ENV=development rake assets:precompile]
    Rake::Task['assets:precompile'].invoke
    puts "end compile, cost: #{Time.now - begin_time} seconds"
  end
  listener.start
  $robin8_root_path = Rails.root

  module Sprockets
    module Rails
      module Helper
        def javascript_include_tag(*sources)
          options = sources.extract_options!.stringify_keys
          if sources.count == 1
            Dir.glob("#{$robin8_root_path}/public/assets/*").each do |file_path|
              base_name = File.basename(file_path)
              if Regexp.new("^#{sources[0]}.+js").match(base_name)
                return "<script src=/assets/#{base_name}></script>".html_safe
              end
            end
          end

          $cache = ActionController::Base.cache_store
          key = "javascript_cache_in_development"
          js_html = ""
          
          value = $cache.fetch(key)
          return value if value.present?

          if options["debug"] != false && request_debug_assets?
            js_html = sources.map { |source|
              check_errors_for(source, :type => :javascript)
              if asset = lookup_asset_for_path(source, :type => :javascript)
                asset.to_a.map do |a|
                  super(path_to_javascript(a.logical_path, :debug => true), options)
                end
              else
                super(source, options)
              end
            }.flatten.uniq.join("\n").html_safe
          else
            sources.push(options)
            js_html = super(*sources)
          end
          $cache.write(key, js_html)
          return js_html
        end
      end
    end
  end
end