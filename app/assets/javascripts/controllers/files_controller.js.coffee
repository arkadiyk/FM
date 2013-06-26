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


FM.FilesController = Ember.ObjectController.extend
  cols: null
  gridItems: (->
    console.log('about to do content', @get('cols'))
    ret = []
    return ret unless @get('cols')
    console.log('generating content', @get('cols'))

    cols = @get('cols')
    current_col = 0

    pushCol = (col) ->
      ret.push(col)
      current_col++
      current_col = 0 if current_col == cols

    pushDir = (col) ->
      if current_col > 0
        for i in [current_col...cols]
          ret.push FM.GridElement.create( type: 'empty_filler', title: "e:#{i}" )

      ret.push(col)
      for i in [1...cols]
        ret.push FM.GridElement.create( type: 'dir_filler', title: "d:#{i}" )
      current_col = 0

    @get('allFiles').forEach (folder) ->
      pushDir(FM.GridElement.create( type: 'dir', titles: folder.get('titles') ))
      folder.get('files').forEach (file) -> pushCol(file)
    ret
  ).property('cols', 'content')

