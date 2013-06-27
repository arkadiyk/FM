FM.GridElement = Ember.Object.extend
  isDir: (->
    @get('type') == 'dir'
  ).property('type')
  isDirFiller: (->
    @get('type') == 'dir_filler'
  ).property('type')
  isEmptyFiller: (->
    @get('type') == 'empty_filler'
  ).property('type')
  isLastDirFiller: (->
    @get('type') == 'last_dir_filler'
  ).property('type')


FM.FilesController = Ember.ObjectController.extend
  cols: null
  collapsed: Ember.Set.create([])

  collapse: (folder) ->
    id = folder.get('folder.id')
    if @get('collapsed').contains(id)
      @get('collapsed').remove(id)
    else
      @get('collapsed').add(id)


  gridItems: (->
    console.log('about to do content', @get('cols'))
    ret = []
    return ret unless @get('cols')

    cols = @get('cols')
    current_col = 0

    pushCol = (col) ->
      ret.push(col)
      current_col++
      current_col = 0 if current_col == cols

    pushDir = (col) =>
      collapsed = @get('collapsed').contains(col.get('id'))
      if current_col > 0
        for i in [current_col...cols]
          ret.push FM.GridElement.create( type: 'empty_filler', title: "e:#{i}" )

      ret.push(FM.GridElement.create( type: 'dir', titles: col.get('titles') ))
      for i in [1...(cols - 1)]
        ret.push FM.GridElement.create( type: 'dir_filler', title: "d:#{i}" )
      if cols > 1
        ret.push FM.GridElement.create( type: 'last_dir_filler', folder: col, isCollapsed: collapsed )
      current_col = 0

    @get('allFiles').forEach (folder) =>
      pushDir(folder)
      unless @get('collapsed').contains(folder.get('id'))
        folder.get('files').forEach (file) -> pushCol(file)
    ret
  ).property('cols', 'content', 'collapsed.[]')

