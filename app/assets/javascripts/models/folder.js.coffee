FM.Folder = Ember.Object.extend
  files: null
  childIds: null
  parents: null

  init: () ->
    @_super()
    @set('parents', []) unless @get('parents')
    @set('files', []) unless @get('files')
    @set('childIds', []) unless @get('childIds')

  children: (->
    @get('childIds').map (id) -> FM.drive.findFolder(id)
  ).property('childIds.@each')

  allChildrenFiles: ( ->
    list = []
    list.push(file) for file in @get('files')
    @get('children').forEach (child) ->
      child.get('allChildrenFiles').forEach (fl) ->
        list.push(fl)
    list
  ).property('children.@each')

  allChildrenUnprocessedFiles: ( ->
    @get('allChildrenFiles').filter (e) -> !e.get('fotomoo')
  ).property('allChildrenFiles')

  childrenWithUnprocessedFiles: ( ->
    @get('children').filter (e) -> e.get('allChildrenUnprocessedFiles.length')
  ).property('allChildrenUnprocessedFiles', 'children.@each')


  folderPath: (->
    full_name = [@get('title')]
    parent_ref = @.get('parents.0')
    while parent_ref and not parent_ref?.isRoot
      parent = FM.Folder.find(parent_ref.id)
      full_name.unshift(parent.get('title'))
      parent_ref = parent.get('parents.0')

    full_name.unshift(FM.Folder.find('root').get('title'))
    full_name
  ).property('parents')


  flatChildren: (->
    list = []
    if @get('allChildrenUnprocessedFiles.length')
      list.push(@)
      @get('children').forEach (child) ->
        child.get('flatChildren').forEach (fc) -> list.push(fc)
    list
  ).property('children.@each')


FM.Folder.reopenClass
  find: (fid) -> FM.drive.findFolder(fid)
