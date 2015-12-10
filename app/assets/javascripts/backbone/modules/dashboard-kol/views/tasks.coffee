Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.TaskContainer = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/tasks-layout'

    regions:
      currentTab: '.currentTab'

    ui:
      loading: '.loadingOfTasks'
      loadMore: '.loadMore'
      noMore: '.noMore'

    events:
      'click .tasks-nav li': 'switchTab'
      'click .loadMore': 'loadMore'

    onRender: () ->
      @tasks = new Robin.Collections.CampaignDiscovers([], {type:'upcoming', limit: 3, offset: 0})
      @tasksView = new Show.Tasks
        collection: @tasks
      @tasks.fetch
        success: (collection, res, opts) =>
          console.log 'get tasks: ', collection
          @ui.loading.hide()
          @getRegion('currentTab').show @tasksView

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

  Show.Tasks = Backbone.Marionette.CollectionView.extend
    childView: Show.Task
    childViewContainer: 'ul'
