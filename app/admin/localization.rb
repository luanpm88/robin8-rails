ActiveAdmin.register_page "Localization" do

  controller do
    before_filter :get_locales
    def get_locales
      @l ||= Localization.new
    end
    def apply h, new_value, locale
      keys = new_value['key'].split('.')
      deep_send h, new_value, keys, locale
    end

    def deep_send h, new_value, keys, locale, index = 0
      if h[keys[index]].class == ActionController::Parameters
        deep_send(h[keys[index]], new_value, keys - [keys[index]], locale, index)
      else
        if index == (keys.length - 1)
          h[keys[index]] = new_value[locale]
        else
          h[keys[index]] = {}
          deep_send(h.send('[]', keys[index]), new_value, keys, locale, index + 1)
        end
      end
    end

    def top_level_valid? key, h
      errors = []
      errors << "The key already exists" if h.has_key?(key)
      errors << "The key should consists only of alphanumber characters" unless alpha?(key)
      return errors
    end

    def alpha? key
      !!key.match(/^\w+$/)
    end
  end

  content do
    l ||= Localization.new
    menu_items = JSON.parse(l.store.get('en'))['application'].keys
    render partial: 'menu', locals: { menu_items: menu_items }
  end

  page_action :section, method: :get do
    @page_title = params[:name].humanize
    @l_en = JSON.parse(@l.store.get('en'))['application']["#{params[:name]}"]
    @l_zh = JSON.parse(@l.store.get('zh'))['application']["#{params[:name]}"]
    @key_label = @text_field_name = params[:name]
  end

  page_action :top_level, method: :get do
    @key = nil
    @errors = []
  end

  page_action :add_top_level, method: :post do
    @l_zh = JSON.parse(@l.store.get('zh'))
    @l_en = JSON.parse(@l.store.get('en'))
    if top_level_valid?(params[:key], @l_en['application']).length == 0
      @l_zh['application'][params[:key]] = {}
      @l_en['application'][params[:key]] = {}
      @l.store.set('en', @l_en.to_json)
      @l.store.set('zh', @l_zh.to_json)
      redirect_to admin_localization_path,
        notice: "You've successfully added new top level section: #{params[:key]}"
    else
      @errors = top_level_valid?(params[:key], @l_en['application'])
      @key = params[:key]
      render :top_level
    end
  end

  page_action :update, method: :post do
    params[:keys].delete_if {|key, item| item['key'].blank? } if params[:keys]

    @l_zh = JSON.parse(@l.store.get('zh'))
    @l_zh['application'][params['section']] = params["zh_#{params[:section]}"] if params["zh_#{params[:section]}"]

    @l_en = JSON.parse(@l.store.get('en'))
    @l_en['application'][params['section']] = params["en_#{params[:section]}"] if params["en_#{params[:section]}"]

    params[:keys].each do |key, new_item|
      @en = JSON.parse(Localization.new.store.get('en'))
      apply(@l_en['application'][params['section']], new_item, 'en')
      apply(@l_zh['application'][params['section']], new_item, 'zh')
    end if params[:keys]

    @l.store.set('en', @l_en.to_json)
    @l.store.set('zh', @l_zh.to_json)

    redirect_to admin_localization_section_path(name: params[:section]),
      notice: "You've successfully updated #{params[:section]} section"
  end

  page_action :delete, method: :delete do
    @l_zh = JSON.parse(@l.store.get('zh'))
    @l_en = JSON.parse(@l.store.get('en'))
    @l_zh['application'].delete(params[:name])
    @l_en['application'].delete(params[:name])
    @l.store.set('en', @l_en.to_json)
    @l.store.set('zh', @l_zh.to_json)
    redirect_to admin_localization_path, notice: "You've successfully deleted #{params[:name]} section"
  end

end




