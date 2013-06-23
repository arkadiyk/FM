FM.FolderListView = Ember.View.extend
  tagName: 'ul'
  templateName: 'folder-list'
  classNames: ['tree-branch', 'nav', 'nav-list']

FM.FolderView = Ember.View.extend
  tagName: 'li'
  templateName: 'folder'
  classNames: ['tree-node']

FM.SelectFolderCheckbox = Em.Checkbox.extend
  checked: true
  checkedObserver: ( ->
    checked = @get('checked')
    file.set('selected', checked) for file in @get('files')
  ).observes('checked')

FM.CopyProgressView = Ember.View.extend
  templateName: 'copy-progress'
  didInsertElement: ->
    @set('queued', 0)
    FM.drive.addObserver 'execQueue.length', =>
      console.log('=============== 1 queue changed:', FM.drive.get('execQueue.length'), FM.drive.get('newFileCount'), FM.drive.get('newFolderCount'))
      @set('queued', FM.drive.get('execQueue.length'))

  willDestroyElement: ->
    FM.drive.removeObserver 'execQueue.length'

  completed: (->
    complete = Math.round(@get('queued') * 100 / (FM.drive.get('newFileCount') + FM.drive.get('newFolderCount')))
    console.log('COMPLETE %%%%%%%%%%', complete, @get('queued'), FM.drive.get('newFileCount'), FM.drive.get('newFolderCount'))
    complete
  ).property('queued')
