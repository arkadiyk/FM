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

FM.GridElementController = Ember.ObjectController.extend
  selectFile: (a) ->
    console.log('SFF', a, @get('content'))


FM.FilesGridController = Ember.ArrayController.extend
  needs: ['files']
  itemController: 'grid-element'

  cols: null
  collapsed: Ember.Set.create([])

  collapse: (folder) ->
    id = folder.get('folder.id')
    if @get('collapsed').contains(id)
      @get('collapsed').remove(id)
    else
      @get('collapsed').add(id)


  content: (->
    folder = @get('controllers.files.content')
    console.log('getting file content:', folder)

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

    folder.get('flatFiles').forEach (fldr) =>
      pushDir(fldr)
      unless @get('collapsed').contains(fldr.get('id'))
        fldr.get('files').forEach (fl) -> pushCol(fl)
    ret
  ).property('cols', 'controllers.files.content', 'collapsed.[]')

