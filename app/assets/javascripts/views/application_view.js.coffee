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