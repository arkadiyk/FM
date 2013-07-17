FM.SetupController = FM.FolderController.extend
  init: ->
    @_super()
    @set('isExpanded', true)

  selectUnprocessedFiles: ->
    root = @get('content')
    root.get('allChildrenUnprocessedFiles').forEach (file) -> file.set('selected', true)


FM.SetupIndexController = FM.FolderController.extend
  copyFiles: ->
    #FM.locationService.loadSelected ->
    FM.drive.createTreeHierarchy()

