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
  ).property('children.@each','files.@each')

  allFiles: (->
    parents = []; list = []
    @_collect_all_files(parents, list)
    list
  ).property('children.@each','files.@each')

  _collect_all_files: (parents, list) ->
    p = parents.copy()
    p.push @get('title')
    list.push {titles: p, files: @get('files')} if @get('files')
    child._collect_all_files(p, list) for child in @get('children')



FM.Folder.reopenClass
  find: (fid) -> FM.drive.findFolder(fid)


FM.File = Ember.Object.extend
  selected: true
  address: (->
    return null if @get("latitude")
    FM.Address.create(latitude: @get("latitude"), longitude: @get("longitude"))
  ).property('latitude')

FM.File.reopenClass
  find: (fid) -> FM.drive.findImageFile(fid)



FM.ViewMode = Ember.Object.extend
  mode: 'list'
  isList: (->
    @get('mode') == 'list'
  ).property('mode')

FM.viewMode = FM.ViewMode.create({})

FM.Address = Ember.Object.extend
  init: ->
    @set('isLoaded', false)
    @load()

  load: ->
    latlng = new google.maps.LatLng(@get("latitude"),@get("longitude"))
    FM.geocoder.geocode {'latLng': latlng}, (results, status) =>
      console.log(results, status)
      @set('formattedAddress', results[1].formatted_address) if(status == 'OK')
      @set('isLoaded', true)






