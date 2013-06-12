FM.drive = FM.Drive.create({})


###
Fotomoo.deferReadiness()
Fotomoo.drive = Fotomoo.Drive.create({})
Fotomoo.userProfile = Ember.Object.create()

Fotomoo.drive.addObserver 'statusMessage', -> $('#load-message').text(Fotomoo.drive.get('statusMessage'))
Fotomoo.drive.addObserver 'statusDetailsMessage', -> $('#load-details-message').text(Fotomoo.drive.get('statusDetailsMessage'))

Fotomoo.drive.addObserver 'filesLoaded', ->
  $('#load').remove()
  Fotomoo.advanceReadiness()

Fotomoo.drive.authorizeOnLoad ->
  Fotomoo.drive.getUserProfile()
  Fotomoo.drive.loadFolders()
  Fotomoo.drive.loadImageFiles()
  ###
