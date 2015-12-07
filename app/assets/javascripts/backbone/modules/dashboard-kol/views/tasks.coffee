Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.Tasks = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/tasks-layout'

    regions:
      currentTab: '.currentTab'

    events:
      'click .tasks-nav li': 'switchTab'

    switchTab: (e) ->
      e.preventDefault()
      @activeNav e.target
      target = @getTargetBy e.target.innerText

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

    getTargetBy: (text) ->
      switch text
        when 'Done' then 'Done'
        when 'Current' then 'Current'
        when 'Upcoming' then 'Upcoming'

  Show.Task = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/task-item'
