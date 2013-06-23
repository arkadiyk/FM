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

FM.Address = Ember.Object.extend
  init: ->
    @set('isLoaded', false)
  formattedAddress: (->
    console.log('fa0',@get('details'), @get('details.1'),@get('details.1.formatted_address'))
    @get('details.1.formatted_address')
  ).property('details')




FM.Address.reopenClass
  _aChache: Ember.Map.create({})
  find: (latitude, longitude) ->
    rr = (n) -> (Math.round(n * 1000) / 1000)
    console.log(latitude, longitude)
    [lat, lon] = [rr(latitude), rr(longitude)]
    key = "#{lat},#{lon}"
    addr = @_aChache.get(key)
    unless addr
      addr = FM.Address.create {latitude,longitude}
      @queue(addr)
      @_aChache.set(key, addr)
      console.log('new:', key)
    else
      console.log('found!:', key)
    addr

  _aQueue: []
  _queue_running: false
  _timeout: 400
  queue: (addr) ->
    console.log('queue', @_queue_running, @_aQueue.length)
    process = =>
      @_queue_running = true
      if @_aQueue.length
        addr = @_aQueue.shift()
        @load addr.get("latitude"), addr.get("longitude"), (results, status) =>
          console.log('got:', results, status)
          if status == 'OVER_QUERY_LIMIT'
            @_aQueue.push(addr)
            console.log('retrying:', @_timeout * 4)
            setTimeout  process, (@_timeout * 4)
          else
            if(status == 'OK')
              addr.setProperties(details: results)
            else
              addr.set('error', status)

            addr.set('isLoaded', true)
            setTimeout process, @_timeout

      else
        console.log('Stopping the queue')
        @_queue_running = false

    @_aQueue.push(addr)
    setTimeout(process, 100) unless @_queue_running
    @_queue_running = true

  load: (lat,lon,callback) ->
    console.log(lat,lon)
#    latlng = new google.maps.LatLng(lat,lon)
#    FM.geocoder.geocode {'latLng': latlng}, callback
    callback(null, 'DISABLED')






