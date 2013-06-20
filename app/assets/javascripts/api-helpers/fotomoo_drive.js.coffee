FM.Drive = Ember.Object.extend
  driveFolderObjectCache: Ember.Map.create({})
  driveImageFileObjectCache: Ember.Map.create({})
  userProfile: Ember.Object.create()
  activeCallCount: 0
  userProfileLoading: false
  userProfileLoaded: false
  foldersLoading: false
  foldersLoaded: false
  filesLoading: false
  filesLoaded: false
  statusMessage: ''
  statusDetailsMessage: ''

  apiLoaded: ->
    call_count = 0
    execute = (resolve, reject) ->
      if window.gapi and window.gapi.auth
        resolve()
      else
        if call_count++ > 10
          reject('Cannot load Google Drive API')
        else
          setTimeout ( => execute(resolve, reject) ), 37
    new Ember.RSVP.Promise(execute)

  authorize: ->
    execute = (resolve) => @_authorize -> resolve()
    new Ember.RSVP.Promise(execute)

  loadAssets: ->
    tasks = [
      @getUserProfile()
      @loadFolders()
      @loadImageFiles()
    ]
    Ember.RSVP.all(tasks)

  getUserProfile: ->
    @set('statusMessage', 'Authorizing ...')
    @set('userProfileLoading', true)
    profile = @get('userProfile')
    execute = (resolve, reject) =>
      callback = (result) =>
        profile.setProperties(result)
        @setProperties(userProfileLoading: false, userProfileLoaded: true)
        resolve()
      @_execute('about.get', {fields: 'name,user'}, callback )
    new Ember.RSVP.Promise(execute)

  loadFolders: () ->
    @set('statusMessage', 'Loading Folders ...')
    execute = (resolve) =>
      process_folders = (folders) =>
        folders.root = {id: 'root', title: 'Root Folder', childIds: [], files: [], parents:[]}
        for fid, folder of folders
          for parent in folder.parents
            pid = if parent.isRoot then 'root' else parent.id
            folders[pid].childIds ||= []
            folders[pid].childIds.push fid

        for fid, folder of folders
          fo = FM.Folder.create(folder)
          @get('driveFolderObjectCache').set(fid, fo)
          #@set('fotomooFolder', fo) if folder.title == 'Fotomoo Pictures'

        for fid, folder of folders
          continue unless folder.childIds
          fo = @get('driveFolderObjectCache').get(fid)
          children = (@get('driveFolderObjectCache').get(child_id) for child_id in folder.childIds)
          fo.set('children',children)

        @setProperties(foldersLoading: false, foldersLoaded: true)
        resolve()

      params =
        q: "mimeType = 'application/vnd.google-apps.folder'"
        fields: "items(id,parents(id,isRoot),title),nextPageToken"
      @setProperties(foldersLoading: true, foldersLoaded: false)
      @_loadFiles(params, process_folders)
    new Ember.RSVP.Promise(execute)

  loadImageFiles: ->
    @set('statusMessage', 'Loading Files ...')
    execute = (resolve) =>
      process_files = (files) =>
        for fid, file_json of files
          file = FM.File.create(file_json)
          @get('driveImageFileObjectCache').set(fid, file)
          for parent in file_json.parents
            pid = if parent.isRoot then 'root' else parent.id
            folder = @findFolder(pid)
            folder.set('files',[]) unless folder.get('files')
            folder.get('files').addObject(file)
        @setProperties(filesLoading: false, filesLoaded: true)
        resolve()

      params =
        q: "mimeType contains 'image'"
        fields: "items(description,fileSize,id,imageMediaMetadata(cameraMake,cameraModel,date,height,width,location),indexableText,mimeType,parents(id,isRoot),thumbnailLink,title),nextPageToken"
      @setProperties(filesLoading: true, filesLoaded: false)
      @_loadFiles(params, process_files)

    new Ember.RSVP.Promise(execute)


  findFolder: (fid) -> @get('driveFolderObjectCache').get(fid)
  findImageFile: (fid) -> @get('driveImageFileObjectCache').get(fid)

  allSelectedImages: ->
    selected = []
    @get('driveImageFileObjectCache').forEach (fid, file) ->
      selected.push(file) if file.get('selected')
    selected

  createTree: (folder_def, root) ->
    folder_def.parents = [{id: root.get('id')}]
    @_createFolder folder_def, (new_folder_json) =>
      new_folder = FM.Folder.create(new_folder_json)
      console.log('created', new_folder_json)
      @_linkFile(file, new_folder, (ret) -> console.log('linked:', ret)) for file in folder_def.files
      @get('driveFolderObjectCache').set(new_folder_json.id, new_folder)
      root.get('childIds').push(new_folder_json.id)
      root.get('children').pushObject(new_folder)
      for child in folder_def.children
        @createTree(child, new_folder)

  _authorize: (success_callback) ->
    CLIENT_ID = '865302316429.apps.googleusercontent.com'
    SCOPES = 'https://www.googleapis.com/auth/drive'
    callback = (auth_result) ->
      if auth_result && !auth_result.error
        success_callback(auth_result)
      else
        gapi.auth.authorize( {client_id: CLIENT_ID, scope: SCOPES, immediate: false}, callback)
    gapi.auth.authorize( {client_id: CLIENT_ID, scope: SCOPES, immediate: true}, callback)

  _execute: (method, params, success_callback, error_callback) ->
    [gapi_area, gapi_call] = method.split('.')
    @incrementProperty('activeCallCount')
    gapi.client.load 'drive', 'v2', =>
      request = gapi.client.drive[gapi_area][gapi_call](params)
      request.execute (result) =>
        if not result
          success_callback({items:[]})
        else if not result.error
          success_callback(result)
        else if result.error.code == 401
          console.log("reathorizing #{method}:", result)
          @_authorize(=> @_execute(method, params, success_callback, error_callback))
        else if result.error.code == 403
        else
          console.log("ERROR!", result)
          error_callback(result) if error_callback
        @decrementProperty('activeCallCount')

  _loadFiles: (params, complete_callback) ->
    files = {}
    callback = (result) =>
      files[file.id] = file for file in result.items
      if result.nextPageToken
        params.pageToken = result.nextPageToken
        @set('statusDetailsMessage', "#{Object.keys(files).length} files loaded")
        @_execute('files.list', params, callback)
      else
        complete_callback(files)
    @_execute('files.list', params, callback)

  _linkFile: (file, folder, callback) ->
    params =
      fileId: file.get('id')
      fields: 'id,title'
      resource:
        parents: [{id: file.get('parents.firstObject.id')}, {id: folder.get('id')}]
    @_execute('files.patch', params, callback)

  _createFolder: (folder, callback) ->
    params =
      fields: 'id,title,parents(id,isRoot)'
      resource:
        title: folder.title
        parents: folder.parents
        mimeType: "application/vnd.google-apps.folder"
    @_execute('files.insert', params, callback)

