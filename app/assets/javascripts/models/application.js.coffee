FM.ViewMode = Ember.Object.extend
  mode: 'list'
  isList: (->
    @get('mode') == 'list'
  ).property('mode')

FM.viewMode = FM.ViewMode.create({})



FM.Config = Ember.Object.extend
  config_format_version: 1
  isDirty: false
  data: ((key, value) ->
    if arguments.length == 1
      addresses: FM.locationService.get('addressCache').copy()
    else
      FM.locationService.get('addressCache').setProperties(value.addresses)
  ).property('FM.locationService.addressCache')

  parseResponse: (data) ->
    for loc_key, addr of data.addresses
      addr_obj = FM.locationService.findByKey(loc_key)
      addr_obj.setProperties(addr)
      addr_obj.setProperties(isLoaded: true, isValid: true)

  json: (->
    jsn = {config_format_version: @get('config_format_version'), addresses: {}}
    FM.locationService.get('addressCache').forEach (loc_key, addr_obj) ->
      if addr_obj.get('isValid')
        jsn.addresses[loc_key] =
          country: addr_obj.get('country')
          pref: addr_obj.get('pref')
          city: addr_obj.get('city')
          formattedAddresses: addr_obj.get('formattedAddresses')

    JSON.stringify(jsn, undefined, 2)

  ).property()


