FM.drive = FM.Drive.create({})
FM.drive.addObserver 'statusMessage', -> Ember.$('#load-message').text(FM.drive.get('statusMessage'))
FM.drive.addObserver 'statusDetailsMessage', -> Ember.$('#load-details-message').text(FM.drive.get('statusDetailsMessage'))

FM.deferReadiness()

FM.drive.apiLoaded().then ->
  FM.drive.authorize()
  FM.geocoder = new google.maps.Geocoder()
.then ->
  FM.drive.loadAssets()
.then ->
  Ember.$('#load').remove()
  FM.advanceReadiness()
.then null, (error_message) ->
  console.log("ERROR:", error_message)
  Ember.$('#load-message').text(error_message)
