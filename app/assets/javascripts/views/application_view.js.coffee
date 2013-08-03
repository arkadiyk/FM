FM.FolderListView = Ember.View.extend
  tagName: 'ul'
  templateName: 'folder-list'
  classNames: ['tree-branch', 'nav', 'nav-list']

FM.FolderView = Ember.View.extend
  tagName: 'li'
  templateName: 'folder'
  classNames: ['tree-node']


FM.CopyProgressView = Ember.View.extend
  completed: (-> "width: #{FM.drive.get('completed')}%").property('FM.drive.completed')
  didInsertElement: -> @$('.modal').modal(keyboard: false, backdrop: 'static')
  willDestroyElement: -> @$('.modal').modal('hide')

FM.LocationServiceProgressView = Ember.View.extend
  completed: (-> "width: #{FM.locationService.get('completed')}%").property('FM.locationService.completed')
  didInsertElement: -> @$('.modal').modal(keyboard: false, backdrop: 'static')
  willDestroyElement: -> @$('.modal').modal('hide')

FM.LoadingView = Ember.View.extend
  didInsertElement: -> @$('.modal').modal(keyboard: false, backdrop: 'static')
  willDestroyElement: -> @$('.modal').modal('hide')
  isChrome: (->
    test = /chrome/.test(navigator.userAgent.toLowerCase())
    console.log('Chrome', test)
    test
  ).property()
  isFirefox: (->
    test = /firefox/.test(navigator.userAgent.toLowerCase())
    console.log('Chrome', test)
    test
  ).property()


FM.ManageView = Ember.View.extend
  didInsertElement: -> @$('.btn-with-popover').popover(trigger: 'hover', placement: 'top')

FM.AboutView = Ember.View.extend
  didInsertElement: -> @$('.link-with-popover').click(-> false).popover
    trigger: 'hover'
    placement: 'top'
    html: true