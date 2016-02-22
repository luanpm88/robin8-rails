Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.TaskContainer = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/tasks-layout'

    regions:
      currentTab: '.currentTab'
      modal: '.task-modal'
      complete_modal: "#complete_modal"

    ui:
      loading: '.loadingOfTasks'
      hasMore: '.loadMore'
      noMore: '.noMore'
      complete_modal: "#complete_modal"

    events:
      'click .tasks-nav li': 'switchTab'
      'click .loadMore': 'loadMore'
      'click .cam-item': 'viewOrShareItem'

    triggerComplete: ()->
      $('#taskModal').modal('hide')
      @base_modal = new Show.ProfileBaseModal
        model: @current_kol
        parent: this
      this.getRegion('complete_modal')
      @showChildView 'complete_modal', @base_modal
      $("#profile-base-modal").modal('show')

    onRender: () ->
      @tasks = new Robin.Collections.CampaignDiscovers([], {type:'upcoming', limit: 3, offset: 0})
      @tasksView = new Show.Tasks
        collection: @tasks
      @tasks.fetch
        success: (collection, res, opts) =>
          console.log 'get tasks: ', collection
          @getRegion('currentTab').show @tasksView
          @updateStatus 'hasMore'

    # status in: hasMore, noMore, loading
    # display status changed out
    updateStatus: (status) ->
      switch status
        when 'hasMore'
          @ui.hasMore.show()
          @ui.loading.hide()
          @ui.noMore.hide()

        when 'noMore'
          @ui.noMore.show()
          @ui.loading.hide()
          @ui.hasMore.hide()

        when 'loading'
          @ui.loading.show()
          @ui.hasMore.hide()
          @ui.noMore.hide()

    viewOrShareItem: (e) ->
      e.preventDefault()
      model_id = e.target.id
      collection = @getRegion('currentTab').currentView.collection
      @model = collection.get(model_id)
      modalView = new Show.TaskModal
        model: @model
        parent: this
      @getRegion('modal').show modalView
      @upload_screenshot_count_down(@model)
      @initQiniuUploader()

    upload_screenshot_count_down: (model) ->
      #清除所有定时任务
      i = 1
      while i < 99999
        window.clearInterval i
        i++
      #计算时间差
      approved_time = new Date(model.get('approved_at'))
      now = new Date
      time_difference = Math.floor((now - approved_time)/1000/60)
      left_time = 30 - time_difference

      if (left_time > 0)
        $('#screenshot-container').hide()
        $('#upload-tip').show()
        $('#upload-tip input').val("剩余" + left_time + "分钟")
        left_time--
      else
        $('#screenshot-container').show()
        $('#upload-tip').hide()

      countdown = setInterval(( ->
        if (left_time > 0)
          $('#screenshot-container').hide()
          $('#upload-tip').show()
          $('#upload-tip input').val("剩余" + left_time + "分钟")
        else
          $('#screenshot-container').show()
          $('#upload-tip').hide()
        if left_time <= 0
          clearInterval countdown
        left_time--
      ), 1000*60)

    initQiniuUploader: ->
      parentThis = @
      uploader = Qiniu.uploader(
        parentThis: parentThis
        runtimes: 'html5,flash,html4'
        browse_button: 'upload-screenshot'
        uptoken_url: '/users/qiniu_uptoken'
        unique_names: true
        domain: '7xozqe.com1.z0.glb.clouddn.com'
        container: 'screenshot-container'
        max_file_size: '100mb'
        flash_swf_url: 'js/plupload/Moxie.swf'
        max_retries: 3
        # dragdrop: true
        # drop_element: 'screenshot-container'
        chunk_size: '4mb'
        auto_start: true
        filters: mime_types: [ {
          title: 'Image files'
          extensions: 'jpg,jpeg,gif,png'
        } ]
        init:
          'FilesAdded': (up, files) ->
            plupload.each files, (file) ->
              # 文件添加进队列后,处理相关的事情
              return
            return
          'BeforeUpload': (up, file) ->
            # 每个文件上传前,处理相关的事情
            return
          'UploadProgress': (up, file) ->
            # 每个文件上传时,处理相关的事情
            return
          'FileUploaded': (up, file, info) ->
            domain = up.getOption('domain')
            res = jQuery.parseJSON(info)
            sourceLink = 'http://' + domain + '/' + res.key
            $('#show-screenshot').attr 'src', sourceLink
            $('input[name=screenshot]').val sourceLink
            console.log 'after upload success: ', up.getOption('parentThis').model
            model = up.getOption('parentThis').model

            console.log 'start save: '
            model.save screenshot: sourceLink,
              success: (m, r, o) =>
                $.growl
                  message: '上传截图成功，我们将在一个工作日内审核'
                  type: 'success'
                updatedView = new Show.TaskModal
                  model: model
                updatedViewHtml = updatedView.render().$el
                up.getOption('parentThis').$el.find('.modal-body').replaceWith updatedViewHtml.find('.modal-body')
                parentThis.initQiniuUploader()
                console.log 'success'
              error: =>
                $.growl
                  message: '上传失败，请刷新页面重试'
                  type: 'danger'
                console.log 'error'

            #获取上传成功后的文件的Url
            return
          'Error': (up, err, errTip) ->
            #上传出错时,处理相关的事情
            return
          'UploadComplete': ->
            #队列文件处理完毕后,处理相关的事情
            return
      )


    loadMore: (e) ->
      e.preventDefault()
      @updateStatus 'loading'
      currentView = @getRegion('currentTab').currentView
      offset = currentView.$el.find('li').length
      type = currentView.collection.type
      appendTasks = new Robin.Collections.CampaignDiscovers([], {type: type, offset: offset})
      appendTasksView = new Show.Tasks
        collection: appendTasks
      appendTasks.fetch
        success: (collection, res, opts) =>
          if collection.models.length == 0
            @updateStatus 'noMore'
          else if res.error == 'error type!'
            @updateStatus 'noMore'
          else
            currentView.collection.add appendTasks.toJSON()
            @updateStatus 'hasMore'
        error: =>
          console.log 'fire loadingMore: fetch append tasks error'

    switchTab: (e) ->
      e.preventDefault()
      @activeNav e.target
      target = e.target.id
      @getRegion('currentTab').reset()
      @updateStatus 'loading'
      $('span.badge').remove()
      Show.CustomController.switchCampaignsTabTo target, @getRegion('currentTab'), @ui.loading
      @updateStatus 'hasMore'

    showTabFor: (target) ->
      task = new Show.Task
      @getRegion('currentTab').show task

    activeNav: (targetATag) ->
      $('.tasks-nav li').removeClass('active')
      # You-Dont-Need-jQuery :)
      parentLiTag = targetATag.parentNode
      if parentLiTag.classList
        parentLiTag.classList.add 'active'
      else
        parentLiTag.className += ' ' + 'active'


  Show.Task = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/task-item'
    tagName: 'li'

    serializeData: () ->
      item: @model.toJSON()
      start_at: @format_date(@model.get('start_time'))
      end_at: @format_date(@model.get('deadline'))

    format_date: (date) ->
      localDate = new Date(date)
      formatted_date = localDate.getFullYear() + '年' + (localDate.getMonth() + 1) + '月' + localDate.getDate() + '日' + localDate.getHours() + '时' + localDate.getMinutes() + '分'

  Show.Tasks = Backbone.Marionette.CollectionView.extend
    childView: Show.Task
    childViewContainer: 'ul'

  Show.TaskModal = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/task-modal'

    events:
      'click .triggerMark': 'markAsRunning'
      'click .fixup-profile': 'fixupProfile'
      'click .triggerComplete': 'triggerComplete'

    fixupProfile: (e) ->
      $('#taskModal').modal('hide')

    initialize: (opts) ->
      @model = opts.model
      @parent = opts.parent
      @current_kol = new Robin.Models.KolProfile App.currentKOL.attributes
      @needMobile = opts.needMobile
      @finished = opts.finished
      if @current_kol.attributes.category_size == 0 || @current_kol.attributes.mobile_number == ""
        @needComplete = true
      else
        @needComplete = false

    serializeData: () ->
      item: @model.toJSON()
      start_at: @format_date(@model.get('start_time'))
      end_at: @format_date(@model.get('deadline'))
      needMobile: @needMobile
      finished: @finished
      needComplete: @needComplete

    format_date: (date) ->
      localDate = new Date(date)
      formatted_date = localDate.getFullYear() + '年' + (localDate.getMonth() + 1) + '月' + localDate.getDate() + '日' + localDate.getHours() + '时' + localDate.getMinutes() + '分'

    triggerComplete: (e) ->
      @parent.triggerComplete()

    markAsRunning: (e) ->
      e.preventDefault()
      parentThis = @
      $.ajax
        type: 'get'
        url: '/mark_as_running/' + @model.get('id')
        dataType: 'json'
        success: (data) ->
          if data.status == 'ok'
            parentThis.model.collection.remove parentThis.model
            $('a#running').append('<span class="badge">1</span>')
            parentThis.model.set('status', 'approved')
            updatedView = new Show.TaskModal
              model: parentThis.model
            updatedViewHtml = updatedView.render().$el
            parentThis.$el.find('.modal-body').replaceWith updatedViewHtml.find('.modal-body')
            $('.triggerMark').remove()
            parentThis.upload_screenshot_count_down()
            parentThis.initQiniuUploader()
          else if data.status == 'needMobile'
            console.log 'need mobile'
            updatedView = new Show.TaskModal
              model: parentThis.model
              needMobile: true
            updatedViewHtml = updatedView.render().$el
            parentThis.$el.find('.modal-body').replaceWith updatedViewHtml.find('.modal-body')
          else if data.status == 'campaign finished'
            updatedView = new Show.TaskModal
              model: parentThis.model
              finished: true
            updatedViewHtml = updatedView.render().$el
            parentThis.$el.find('.modal-body').replaceWith updatedViewHtml.find('.modal-body')

    onShow: () ->
      @initQiniuUploader()
      $('#taskModal').modal()
      clipboard = new Clipboard('.task-modal-btn');

    onRender: ()->
      @initQiniuUploader()

    initQiniuUploader: ->
      parentThis = @
      uploader = Qiniu.uploader(
        parentThis: parentThis
        runtimes: 'html5,flash,html4'
        browse_button: 'upload-screenshot'
        uptoken_url: '/users/qiniu_uptoken'
        unique_names: true
        domain: '7xozqe.com1.z0.glb.clouddn.com'
        container: 'screenshot-container'
        max_file_size: '100mb'
        flash_swf_url: 'js/plupload/Moxie.swf'
        max_retries: 3
        # dragdrop: true
        # drop_element: 'screenshot-container'
        chunk_size: '4mb'
        auto_start: true
        filters: mime_types: [ {
          title: 'Image files'
          extensions: 'jpg,jpeg,gif,png'
        } ]
        init:
          'FilesAdded': (up, files) ->
            plupload.each files, (file) ->
              # 文件添加进队列后,处理相关的事情
              return
            return
          'BeforeUpload': (up, file) ->
            # 每个文件上传前,处理相关的事情
            return
          'UploadProgress': (up, file) ->
            # 每个文件上传时,处理相关的事情
            return
          'FileUploaded': (up, file, info) ->
            domain = up.getOption('domain')
            res = jQuery.parseJSON(info)
            sourceLink = 'http://' + domain + '/' + res.key
            $('#show-screenshot').attr 'src', sourceLink
            $('input[name=screenshot]').val sourceLink
            console.log 'after upload success: ', up.getOption('parentThis').model
            model = up.getOption('parentThis').model

            console.log 'start save: '
            model.save screenshot: sourceLink,
              success: (m, r, o) =>
                $.growl
                  message: '上传截图成功，我们将在一个工作日内审核'
                  type: 'success'
                updatedView = new Show.TaskModal
                  model: model
                updatedViewHtml = updatedView.render().$el
                up.getOption('parentThis').$el.find('.modal-body').replaceWith updatedViewHtml.find('.modal-body')
                parentThis.initQiniuUploader()
                console.log 'success'
              error: =>
                $.growl
                  message: '上传失败，请刷新页面重试'
                  type: 'danger'
                console.log 'error'

            #获取上传成功后的文件的Url
            return
          'Error': (up, err, errTip) ->
            #上传出错时,处理相关的事情
            return
          'UploadComplete': ->
            #队列文件处理完毕后,处理相关的事情
            return
      )

    upload_screenshot_count_down: () ->
      #清除所有定时任务
      i = 1
      while i < 99999
        window.clearInterval i
        i++
      #计算时间差
      # approved_time = new Date(@model.get('approved_at'))
      # now = new Date
      # time_difference = (now - approved_time)/1000

      left_time = 30

      if left_time >= 0
        $('#upload-screenshot').hide()
        $('#upload-tip').show()
        $('#upload-tip input').val("剩余" + left_time + "分钟")
        left_time--
      else
        $('#upload-screenshot').show()
        $('#upload-tip').hide()

      countdown = setInterval(( ->
        if left_time > 0
          $('#upload-screenshot').hide()
          $('#upload-tip').show()
          $('#upload-tip input').val("剩余" + left_time + "分钟")
        else
          $('#upload-screenshot').show()
          $('#upload-tip').hide()
        if left_time < 0
          clearInterval countdown
        left_time--
      ), 1000*60)
