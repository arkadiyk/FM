FM.Folder = Ember.Object.extend
  files: null
  childIds: []
  children: []

  childrenWithPictures: (->
    f for f in @get('children') when f.get('totalFileCount') > 0
  ).property('children.@each.totalFileCount')

  totalFileCount: (->
    count = if @get('files') then @get('files').get('length') else 0
    count += f.get('totalFileCount') for f in @get('children')

    count
  ).property() # 'children.@each','files.@each'

  flatFiles: (->
    parents = []; list = []
    @_collect_all_files(parents, list)
    list
  ).property('children.@each','files.@each')

  _collect_all_files: (parents, list) ->
    p = parents.copy()
    p.push @get('title')
    list.push Ember.Object.create(id: @get('id'), titles: p, files: @get('files')) if @get('files')
    child._collect_all_files(p, list) for child in @get('children')



FM.Folder.reopenClass
  find: (fid) -> FM.drive.findFolder(fid)


FM.File = Ember.Object.extend
  isFile: true
  selected: true
  address: (->
    return null unless @get("imageMediaMetadata.location.latitude")
    FM.Address.find(@get("imageMediaMetadata.location.latitude"), @get("imageMediaMetadata.location.longitude"))
  ).property()
  year: (->
    date = @get('imageMediaMetadata.date')
    if date
      (@get('imageMediaMetadata.date').split(' ')[0]).split(':')[0]
    else
      "unknown"
  ).property('imageMediaMetadata.date')
  month: (->
    date = @get('imageMediaMetadata.date')
    if date
      (@get('imageMediaMetadata.date').split(' ')[0]).split(':')[1]
    else
      "unknown"
  ).property('imageMediaMetadata.date')

FM.File.reopenClass
  find: (fid) -> FM.drive.findImageFile(fid)



FM.ViewMode = Ember.Object.extend
  mode: 'list'
  isList: (->
    @get('mode') == 'list'
  ).property('mode')

FM.viewMode = FM.ViewMode.create({})







