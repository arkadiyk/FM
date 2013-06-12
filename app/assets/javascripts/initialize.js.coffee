FM.drive = FM.Drive.create({})

FM.drive.addObserver 'statusMessage', -> Ember.$('#load-message').text(FM.drive.get('statusMessage'))
FM.drive.addObserver 'statusDetailsMessage', -> Ember.$('#load-details-message').text(FM.drive.get('statusDetailsMessage'))

FM.deferReadiness()

FM.drive.apiLoaded().then ->
  FM.drive.authorize()
.then ->
  FM.drive.loadAssets()
.then ->
  $('#load').remove()
  FM.advanceReadiness()
.then null, (error_message) ->
  console.log("ERROR:", error_message)
  Ember.$('#load-message').text(error_message)



#
#Ember.Application.initializer
#  name: 'initial_loads'
#  initialize: (container, app) ->
#    FM.deferReadiness()
#


###
Fotomoo.deferReadiness()
Fotomoo.drive = Fotomoo.Drive.create({})


Fotomoo.drive.addObserver 'filesLoaded', ->
  $('#load').remove()
  Fotomoo.advanceReadiness()

Fotomoo.drive.authorizeOnLoad ->
  Fotomoo.drive.getUserProfile()
  Fotomoo.drive.loadFolders()
  Fotomoo.drive.loadImageFiles()
  ###
