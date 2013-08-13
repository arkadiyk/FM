module "Google Drive API Wrapper",
  setup: -> Ember.run(FM, FM.advanceReadiness)
  teardown: -> FM.reset()

asyncTest "Get Folders", ->
  expect(5)
  drive = FM.Drive.create({})
  ok(!drive.get('foldersLoaded'), "Folders are not loaded initially")
  drive.loadFolders().then ->
    ok(drive.get('foldersLoaded'), "Folders should be loaded")
    equal(drive.get('driveFolderObjectCache.length'), 21, 'Should be loaded 21 folders')
    ok(drive.get('driveFolderObjectCache').get('root'), 'Root folder should be defined')
    ok(drive.get('fotomooFolder'), 'Fotomoo Folder should be there')
    start()


