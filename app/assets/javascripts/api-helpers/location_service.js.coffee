FM.LocationService = Ember.Object.extend
  _aCache: Ember.Map.create({})
  find: (latitude, longitude) ->
    rr = (n) -> (Math.round(n * 100) / 100)
    [lat, lon] = [rr(latitude), rr(longitude)]
    id = "#{lat},#{lon}"
    addr = @_aCache.get(id)
    unless addr
      addr = FM.Address.create {id,latitude,longitude}
      @_aCache.set(id, addr)
    addr

  loadSelected: (complete_callback) ->
    selectedAddresses = Ember.Map.create({})
    FM.Folder.find('root').get('allChildrenSelectedFiles').forEach (file) ->
      address = file.get('address')
      selectedAddresses.set(address.get('id'), address) if address

    addresses = []
    selectedAddresses.forEach (id, addr) ->
      addresses.push(addr) unless addr.get('isLoaded')

    if window.google and google.maps
      @_load(addresses, complete_callback)
    else
      Ember.$.getScript GLOCSCRIPT, =>
        google.load 'maps', '3.exp', other_params: 'sensor=false', callback: =>
          @geocoder = new google.maps.Geocoder()
          @_load(addresses, complete_callback)


  toProcessCount: 0
  processedCount: 0
  addressObtained: ''

  _load: (addresses, complete_callback) ->
    try_count = 0
    timeout = 500
    current_timeout = timeout
    @set('toProcessCount', addresses.length)
    @set('processedCount', 0)

    process = =>
      if addresses.length
        addr = addresses.shift()
        @_google_load addr.get("latitude"), addr.get("longitude"), (results, status) =>
          console.log('got from google:', results, status)
          switch status
            when 'OK'
              addr_json = @_parseResponse(results)
              addr.setProperties addr_json
              addr.set('dirty', true)
              @set('addressObtained', addr_json.formattedAddresses[1])
              @incrementProperty('processedCount')
              try_count = 0
              current_timeout = timeout
            when 'OVER_QUERY_LIMIT'
              if try_count > 5
                addr.setProperties(isError: true, errorMessage: "QUERY_LIMIT failed more than 5 times")
                addresses = [] # do not abuse google api
              else
                try_count++
                addresses.push(addr)
                current_timeout = (timeout * 10 * try_count)
                @set('addressObtained', "Google Map API query limit reached. Retrying")
            else
              if try_count > 3
                addr.setProperties(isError: true, errorMessage: status)
                addresses = [] # do not abuse google api
              else
                try_count++
                addresses.push(addr)
                current_timeout = (timeout * 20 * try_count)

          addr.set('isLoaded', true)
          setTimeout process, current_timeout
      else
        @set('toProcessCount', 0)
        @set('processedCount', 0)
        complete_callback()

    setTimeout(process, 10)

  _google_load: (lat,lon,callback) ->
    latlng = new google.maps.LatLng(lat,lon)
    @geocoder.geocode {'latLng': latlng}, callback

  _parseResponse: (response) ->
   address = {formattedAddresses: []}
   response.forEach (detail) ->
     address.formattedAddresses.push detail.formatted_address
     detail.address_components.forEach (comp) ->
       address.country = comp.long_name if comp.types[0] == 'country'
       address.pref =  comp.long_name if comp.types[0] == 'administrative_area_level_1'
       address.city =  comp.long_name if comp.types[0] == 'locality'
   address

  completed: (->
    Math.round(@get('processedCount') * 100 / (@get('toProcessCount')))
  ).property('toProcessCount', 'processedCount')
