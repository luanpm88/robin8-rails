module ApplicationHelper
  def env_javascript_include_tag(args = {})
    send_tag_method(:javascript_include_tag, args)
  end

  def env_stylesheet_link_tag(args = {})
    send_tag_method(:stylesheet_link_tag, args)
  end

  def use_hot_reloading?
    ENV["REACT_ON_RAILS_ENV"] == "HOT"
  end

  def smart_root_url path, opts={}
    URI.join(root_url(opts), path).to_s
  end

  def show_percentage(ele)
    number_to_percentage(ele * 100, precision: 0)
  end

  private

  def send_tag_method(tag_method_name, args)
    asset_type = use_hot_reloading? ? :hot : :static
    assets = Array(args[asset_type])
    options = args.delete_if { |key, _value| %i(hot static).include?(key) }
    send(tag_method_name, *assets, options) unless assets.empty?
  end
end
