#FM.FilesController = Ember.ObjectController.extend
#  flatFiles: (->
#    collect_all_files = (root, parents, list) ->
#      p = parents.copy()
#      p.push root.get('title')
#      if root.get('files')
#        list.push Ember.Object.create(id: root.get('id'), titles: p, files: root.get('files'), isDir: true)
#      collect_all_files(child, p, list) for child in root.get('children')
#
#    parents = []; list = []; root = @get('content')
#    collect_all_files(root, parents, list)
#    list
#  ).property('content')


FM.GridElement = Ember.Object.extend
  isDirFiller:     (-> @get('type') == 'dir_filler' ).property('type')
  isEmptyFiller:   (-> @get('type') == 'empty_filler' ).property('type')
  isLastDirFiller: (-> @get('type') == 'last_dir_filler').property('type')

FM.GridDirElement = Ember.Object.extend
  isDir: true
  selectedFilesCount: (->
    @get('folder.unprocessedFiles').filterProperty('selected', true).get('length')
  ).property('folder.unprocessedFiles.@each.selected')
  isAllSelected: (->
    @get('selectedFilesCount') == @get('folder.unprocessedFiles.length')
  ).property('selectedFilesCount','folder.unprocessedFiles')
  selectLabel: (->
    if @get('isAllSelected') then "Unselect All" else "Select All"
  ).property('isAllSelected')


FM.FilesGridController = Ember.ObjectController.extend
  needs: ['files']

  cols: null
  collapsed: Ember.Set.create([])

  flipSelect: (folder) ->
    select = !folder.get('isAllSelected')
    folder.get('folder.unprocessedFiles').forEach (f) -> f.set('selected', select)

  collapse: (folder) ->
    id = folder.get('folder.id')
    if @get('collapsed').contains(id)
      @get('collapsed').remove(id)
    else
      @get('collapsed').add(id)


  gridContent: (->
    ret = []
    return ret unless @get('cols')

    folder = @get('controllers.files.content')

    cols = @get('cols')
    current_col = 0

    pushCol = (col) ->
      ret.push col
      current_col++
      current_col = 0 if current_col == cols

    pushDir = (col) =>
      collapsed = @get('collapsed').contains(col.get('id'))
      if current_col > 0
        for i in [current_col...cols]
          ret.push FM.GridElement.create( type: 'empty_filler')

      ret.push(FM.GridDirElement.create( folder: col, titles: col.get('folderPath') ))

      for i in [1...(cols - 1)]
        ret.push FM.GridElement.create( type: 'dir_filler')
      if cols > 1
        ret.push FM.GridElement.create( type: 'last_dir_filler', folder: col, isCollapsed: collapsed )
      current_col = 0

    folder.get('flatChildren').forEach (fldr) =>
      if fldr.get('unprocessedFiles.length')
        pushDir(fldr)
        unless @get('collapsed').contains(fldr.get('id'))
          fldr.get('unprocessedFiles').forEach (fl) ->
            fl.set('selected', true)
            pushCol(fl)
    ret
  ).property('cols', 'controllers.files.content', 'collapsed.[]')

