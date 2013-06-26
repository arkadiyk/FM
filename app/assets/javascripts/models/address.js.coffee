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

