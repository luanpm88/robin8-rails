Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.TaskContainer = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/tasks-layout'

    regions:
      currentTab: '.currentTab'
      modal: '.task-modal'

    ui:
      loading: '.loadingOfTasks'
      loadMore: '.loadMore'
      noMore: '.noMore'

    events:
      'click .tasks-nav li': 'switchTab'
      'click .loadMore': 'loadMore'
      'click .cam-item': 'viewOrShareItem'

    onRender: () ->
      @tasks = new Robin.Collections.CampaignDiscovers([], {type:'upcoming', limit: 3, offset: 0})
      @tasksView = new Show.Tasks
        collection: @tasks
      @tasks.fetch
        success: (collection, res, opts) =>
          console.log 'get tasks: ', collection
          @ui.loading.hide()
          @getRegion('currentTab').show @tasksView

    viewOrShareItem: (e) ->
      e.preventDefault()
      model_id = e.target.id
      collection = @getRegion('currentTab').currentView.collection
      model = collection.get(model_id)
      modalView = new Show.TaskModal
        model: model
      @getRegion('modal').show modalView

    loadMore: (e) ->
      e.preventDefault()
      @ui.loadMore.hide()
      @ui.loading.show()
      currentView = @getRegion('currentTab').currentView
      offset = currentView.$el.find('li').length
      type = currentView.collection.type
      appendTasks = new Robin.Collections.CampaignDiscovers([], {type: type, offset: offset})
      appendTasksView = new Show.Tasks
        collection: appendTasks
      appendTasks.fetch
        success: (collection, res, opts) =>
          @ui.loading.hide()
          if collection.models.length == 0
            @ui.noMore.show()
          else
            currentView.collection.add appendTasks.toJSON()
            @ui.loadMore.show()
        error: =>
          console.log 'fire loadingMore: fetch append tasks error'

    switchTab: (e) ->
      e.preventDefault()
      @activeNav e.target
      target = e.target.id
      @getRegion('currentTab').reset()
      @ui.loading.show()
      @ui.noMore.hide()
      @ui.loadMore.show()
      $('span.badge').remove()
      Show.CustomController.switchCampaignsTabTo target, @getRegion('currentTab'), @ui.loading

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

    fixupProfile: (e) ->
      $('#taskModal').modal('hide')

    initialize: (opts) ->
      @model = opts.model
      @needMobile = opts.needMobile

    serializeData: () ->
      item: @model.toJSON()
      start_at: @format_date(@model.get('start_time'))
      end_at: @format_date(@model.get('deadline'))
      needMobile: @needMobile

    format_date: (date) ->
      localDate = new Date(date)
      formatted_date = localDate.getFullYear() + '年' + (localDate.getMonth() + 1) + '月' + localDate.getDate() + '日' + localDate.getHours() + '时' + localDate.getMinutes() + '分'

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
            else if data.status == 'needMobile'
              console.log 'need mobile'
              updatedView = new Show.TaskModal
                model: parentThis.model
                needMobile: true
              updatedViewHtml = updatedView.render().$el
              parentThis.$el.find('.modal-body').replaceWith updatedViewHtml.find('.modal-body')

    onShow: () ->
      $('#taskModal').modal()
      clipboard = new Clipboard('.task-modal-btn');