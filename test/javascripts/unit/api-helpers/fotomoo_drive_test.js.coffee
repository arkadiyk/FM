module "Google Drive API Wrapper: Multiple Pages, Fotomoo Folder, Image Files",
  setup: ->
    Ember.run(FM, FM.advanceReadiness)
    @drive = FM.Drive.create(gapi_mock: (new GapiMock.GapiApi(window.FotomooFixtures01)).getAPI() )
  teardown: -> FM.reset()

asyncTest "Get Folders", ->
  expect(6)
  ok(@drive, "Drive should be initialized")
  ok(!@drive.get('foldersLoaded'), "Folders are not loaded initially")
  @drive.loadFolders().then =>
    ok(@drive.get('foldersLoaded'), "Folders should be loaded")
    equal(@drive.get('driveFolderObjectCache.length'), 21, 'Should be loaded 21 folders')

    root_folder = @drive.get('driveFolderObjectCache').get('root')
    ok(root_folder, 'Root folder should be defined')

    fotomoo_folder = @drive.get('fotomooFolder')
    ok(fotomoo_folder, 'Fotomoo Folder should be there')
    start()


