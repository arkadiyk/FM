FM.ApplicationController = Ember.Controller.extend({})
FM.FolderListController = Ember.ObjectController.extend({})

FM.register('controller:folderList', FM.FolderListController, singleton: false)

FM.FolderController = Ember.ObjectController.extend
  isExpanded: false,
  toggle: -> @set('isExpanded', !this.get('isExpanded'))
  click: -> console.log("Clicked: #{@get('title')}")

FM.register('controller:folder', FM.FolderController, singleton: false)


