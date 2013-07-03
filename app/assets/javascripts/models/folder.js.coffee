FM.Folder = Ember.Object.extend
  files: null
  childIds: []
  children: []

  childrenWithPictures: (->
    f for f in @get('children') when !f.get('fotomoo') and f.get('filesToCopy') > 0
  ).property('children.@each.filesToCopy')

  filesToCopy: (->
    @get('totalFileCount') - @get('fotomooFileCount')
  ).property('totalFileCount', 'fotomooFileCount')

  totalFileCount: (->
    count = if @get('files') then @get('files').get('length') else 0
    count += f.get('totalFileCount') for f in @get('children')
    count
  ).property() # 'children.@each','files.@each'

  fotomooFileCount: (->
    count = if @get('files') then @get('files').filterProperty('fotomoo', true).get('length') else 0
    count += f.get('fotomooFileCount') for f in @get('children')
    count
  ).property() # 'children.@each','files.@each'

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


  flatFiles: (->
    parents = []; list = []
    @_collect_all_files(parents, list)
    list
  ).property('children.@each','files.@each')

  _collect_all_files: (parents, list) ->
    p = parents.copy()
    p.push @get('title')
    if @get('files')
      files =  @get('files').filter((e) -> !e.get('fotomoo'))
      fl.set('selected', true) for fl in files
    else
      files = []

    list.push(Ember.Object.create(id: @get('id'), titles: p, files: files)) if files.length > 0
    child._collect_all_files(p, list) for child in @get('children')



FM.Folder.reopenClass
  find: (fid) -> FM.drive.findFolder(fid)
