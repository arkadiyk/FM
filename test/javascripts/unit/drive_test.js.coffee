module "Google Drive API Wrapper",
  setup: -> Ember.run(FM, FM.advanceReadiness)
  teardown: -> FM.reset()

asyncTest "Get Folders", ->
  drive = FM.Drive.create({})
  ok(!drive.get('foldersLoaded'), "Folders are not loaded initially")
  drive.loadFolders().then ->
    ok(drive.get('foldersLoaded'), "Folders should be loaded")
    equal(drive.get('driveFolderObjectCache.length'), 21, 'Should be loaded 21 folders')
    ok(drive.get('driveFolderObjectCache').get('root'), 'Root folder should be defined')
    ok(drive.get('fotomooFolder'), 'Fotomoo Folder should be there')
    start()


asyncTest "Get Folders (No Any folders on the Drive)", ->
#  window.FotomooFixtures.folders =
#    page0:
#      items: []

  drive = FM.Drive.create({})
  ok(!drive.get('foldersLoaded'), "Folders are not loaded initially")
  drive.loadFolders().then ->
    ok(drive.get('foldersLoaded'), "Folders should be loaded")
    equal(drive.get('driveFolderObjectCache.length'), 21, 'Should be loaded 21 folders')
    ok(drive.get('driveFolderObjectCache').get('root'), 'Root folder should be defined')
    ok(drive.get('fotomooFolder'), 'Fotomoo Folder should be there')
    start()