ActiveAdmin.register_page "Localization" do

  controller do
    before_filter :get_locales
    def get_locales
      @l ||= Localization.new
    end
  end

  content do
    l ||= Localization.new
    menu_items = JSON.parse(l.store.get('en'))['application'].keys
    render partial: 'menu', locals: { menu_items: menu_items }
  end

  page_action :section, method: :get do
    @page_title = params[:name].humanize
    @l_en = JSON.parse(@l.store.get('en'))['application'][params[:name]]
    @l_zh = JSON.parse(@l.store.get('zh'))['application'][params[:name]]
    @key_label = @text_field_name = params[:name]
  end

  page_action :update, method: :post do
    p '~'*90
    p params
    params[:keys].delete_if {|key, item| item['key'].blank? }
    h = {}
    new_translations = apply(h, params[:keys])
    p '*'*90
    p new_translations

    @l_zh = JSON.parse(@l.store.get('zh'))
    # @l_zh['application'][params['section']] = params["zh_#{params[:section]}"]
    # @l.store.set('zh', @l_zh.to_json)

    @l_en = JSON.parse(@l.store.get('en'))
    # @l_en['application'][params['section']] = params["en_#{params[:section]}"]
    # @l.store.set('en', @l_en.to_json)

    params[:keys].each do |key, item|
      @l_en['application'][params['section']][]
    end

    redirect_to admin_localization_section_path(name: params[:section]),
      notice: "You've successfully updated #{params[:section]} section"
  end

  def apply h, arr
    return h if arr.length == 0
    if h[arr[0]].nil? 
      h[arr[0]] = {}
      h[arr[0]] = apply(h[arr[0]], arr - [arr[0]])
    else
      h[arr[0]] = apply(h[arr[0]], arr - [arr[0]]) unless h[arr[0]].class == String
    end
    return h
  end

end