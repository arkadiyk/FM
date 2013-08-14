module "Folder: Multiple Pages, Fotomoo Folder, Image Files",
  setup: ->
    Ember.run(FM, FM.advanceReadiness)
    drive = FM.Drive.create(gapi_mock: (new GapiMock.GapiApi(window.FotomooFixtures01)).getAPI() )
    drive.loadFolders().then =>
      @root_folder = drive.get('driveFolderObjectCache').get('root')
      @fotomoo_folder = drive.get('fotomooFolder')
      start()
    stop()

  teardown: -> FM.reset()

test "Folders available", ->
  ok(@root_folder, 'No Root Folder!')
  ok(@fotomoo_folder, 'No Fotomoo Folder!')


