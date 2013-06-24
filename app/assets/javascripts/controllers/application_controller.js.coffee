FM.ApplicationController = Ember.Controller.extend({})
FM.FolderListController = Ember.ObjectController.extend({})

FM.register('controller:folderList', FM.FolderListController, singleton: false)

FM.FolderController = Ember.ObjectController.extend
  isExpanded: false,
  toggle: -> @set('isExpanded', !this.get('isExpanded'))
  click: -> console.log("Clicked: #{@get('title')}")

FM.register('controller:folder', FM.FolderController, singleton: false)

FM.SetupController = FM.FolderController.extend
  init: ->
    @_super()
    @set('isExpanded', true)

  copyFiles: ->
    root = {}
    selectedFiles = FM.drive.allSelectedImages()
    selectedFiles.forEach (file) ->
      [year, month] = [file.get('year'), file.get('month')]
      root[year] ||= {}
      root[year][month] ||= []
      root[year][month].push(file)

    folder_count = 0; file_count = 0
    pics_root = {title: "Fotomoo Pictures", children: [], files: []}
    for year_name, months of root
      year_obj = {title: year_name, children: [], files: []}
      pics_root.children.push year_obj
      folder_count++
      for month_name, files of months
        month_obj = {title: month_name, children: [], files: []}
        year_obj.children.push month_obj
        folder_count++
        for file in files
          month_obj.files.push file
          file_count++

    FM.drive.set('newFolderCount', folder_count)
    FM.drive.set('newFileCount', file_count)
    FM.drive.createTree(pics_root, FM.Folder.find('root'))


