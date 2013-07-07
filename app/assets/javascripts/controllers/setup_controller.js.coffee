FM.SetupController = FM.FolderController.extend
  init: ->
    @_super()
    @set('isExpanded', true)

FM.SetupIndexController = FM.FolderController.extend
  copyFiles: ->
    root = {}
    selectedFiles = FM.Folder.find('root').get('allChildrenSelectedFiles')
    selectedFiles.forEach (file) ->
      unless file.get('isFotomoo')
        [year, month] = [file.get('year'), file.get('month')]
        root[year] ||= {}
        root[year][month] ||= []
        root[year][month].push(file)

    folder_count = 0; file_count = 0
    pics_root = {children: [], files: []}
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

    FM.drive.createTreeHierarchy(pics_root, folder_count, file_count)

