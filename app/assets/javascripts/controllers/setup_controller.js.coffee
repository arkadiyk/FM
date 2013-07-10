FM.SetupController = FM.FolderController.extend
  init: ->
    @_super()
    @set('isExpanded', true)

  selectUnprocessedFiles: ->
    root = @get('content')
    root.get('allChildrenUnprocessedFiles').forEach (file) -> file.set('selected', true)


FM.SetupIndexController = FM.FolderController.extend
  copyFiles: ->
    by_date = {}
    by_location = {}
    selectedFiles = FM.Folder.find('root').get('allChildrenSelectedFiles')
    selectedFiles.forEach (file) ->
      unless file.get('isFotomoo')
        [year, month] = [file.get('year'), file.get('month')]
        by_date[year] ||= {}
        by_date[year][month] ||= []
        by_date[year][month].push(file)

        [country, pref, city] = [file.get('address.conutry'), file.get('address.pref'), file.get('address.city')]

    folder_count = 0; file_count = 0
    pics_root = {children: [], files: []}
    for year_name, months of by_date
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

    FM.locationService.loadSelected ->
      FM.drive.createTreeHierarchy(pics_root, folder_count, file_count)

