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
