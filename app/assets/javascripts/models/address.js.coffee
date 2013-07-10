FM.Address = Ember.Object.extend
  isLoaded: false
  isError: false

FM.Address.reopenClass
  find: (latitude, longitude) ->
    FM.locationService.find(latitude, longitude)

