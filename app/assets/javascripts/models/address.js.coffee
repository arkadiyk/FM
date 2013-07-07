FM.Address = Ember.Object.extend
  init: ->
    @set('isLoaded', false)
  formattedAddress: (->
    console.log('fa0', @get('details.1.formatted_address'))
    @get('details.1.formatted_address')
  ).property('details')

  country: (->
    @get('_parts').country
  ).property('_parts')

  pref: (->
    @get('_parts').pref
  ).property('_parts')

  city: (->
    @get('_parts').city
  ).property('_parts')

  _parts: (->
    parts = {}
    details = @get('details')
    if details
      details.forEach (detail) ->
        detail.address_components.forEach (comp) ->
          parts.country = comp.long_name if comp.types[0] == 'country'
          parts.pref =  comp.long_name if comp.types[0] == 'administrative_area_level_1'
          parts.city =  comp.long_name if comp.types[0] == 'locality'
    parts
  ).property('details')




FM.Address.reopenClass
  _aChache: Ember.Map.create({})
  find: (latitude, longitude) ->
    rr = (n) -> (Math.round(n * 100) / 100)
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
    FM.geocoder = new google.maps.Geocoder() unless FM.geocoder
    latlng = new google.maps.LatLng(lat,lon)
    FM.geocoder.geocode {'latLng': latlng}, callback

