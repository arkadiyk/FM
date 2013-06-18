FM.ApplicationController = Ember.Controller.extend({})
FM.FolderListController = Ember.ObjectController.extend({})

FM.register('controller:folderList', FM.FolderListController, singleton: false)

FM.FolderController = Ember.ObjectController.extend
  isExpanded: false,
  toggle: -> @set('isExpanded', !this.get('isExpanded'))
  click: -> console.log("Clicked: #{@get('title')}")

FM.register('controller:folder', FM.FolderController, singleton: false)

FM.RootFolderController = FM.FolderController.extend({})

#FM.SetupController = Ember.ObjectController.extend
#  copyFiles: ->
#    root = {}
#    selectedFiles = FM.drive.allSelectedImages()
#    selectedFiles.forEach (file) ->
#      [year, month] = (file.get('imageMediaMetadata.date').split(' ')[0]).split(':')
#      root[year] ||= {}
#      root[year][month] ||= []
#      root[year][month].push(file)
#
#    pics_root = {title: "Fotomoo Pictures", children: [], files: []}
#    for year_name, months of root
#      year_obj = {title: year_name, children: [], files: []}
#      pics_root.children.push year_obj
#      for month_name, files of months
#        month_obj = {title: month_name, children: [], files: []}
#        year_obj.children.push month_obj
#        for file in files
#          month_obj.files.push file
#
#    FM.drive.createTree(pics_root, FM.Folder.find('root'))