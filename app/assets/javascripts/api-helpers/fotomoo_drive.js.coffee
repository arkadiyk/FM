FM.Drive = Ember.Object.extend
  driveFolderObjectCache: Ember.Map.create({})
  driveFolderTitleCache: Ember.Map.create({})
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
        folders.root = {id: 'root', title: 'Root Folder', parents: []}
        for fid, folder of folders
          for parent in folder.parents
            pid = if parent.isRoot then 'root' else parent.id
            folders[pid].childIds ||= []
            folders[pid].childIds.push fid

        for fid, folder of folders
          fo = FM.Folder.create(folder)
          @get('driveFolderObjectCache').set(fid, fo)
          @get('driveFolderTitleCache').set(folder.title, fo)

        mark_children = (ch) ->
          ch.set('isFotomoo', true)
          ch.get('children').forEach (child) -> mark_children(child)
        fotomoo_root = @get('driveFolderTitleCache').get('Fotomoo Pictures')
        mark_children(fotomoo_root)

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
        fields: "items(alternateLink,description,explicitlyTrashed,fileExtension,fileSize,id,imageMediaMetadata(cameraMake,cameraModel,date,height,location,rotation,width),indexableText,md5Checksum,mimeType,openWithLinks,originalFilename,parents(id,isRoot),thumbnailLink,title),nextPageToken"
        maxResults: 500
      @setProperties(filesLoading: true, filesLoaded: false)
      @_loadFiles(params, process_files)

    new Ember.RSVP.Promise(execute)


  findFolder: (fid) -> @get('driveFolderObjectCache').get(fid)
  findImageFile: (fid) -> @get('driveImageFileObjectCache').get(fid)
  rootFolder: ->
    root = @findFolder('root')
    return root if root
    execute = (resolve, reject) =>
      @apiLoaded().then =>
        @authorize()
      .then =>
        @loadAssets()
      .then =>
        resolve(@findFolder('root'))
      .then null, (error_message) ->
        reject(error_message)
    new Ember.RSVP.Promise(execute)

  createTreeHierarchy: ->
    root = FM.Folder.find('root')

    folder_count = 2; file_count = 0
    hash_hierarchy = (h, file, level1_key, level2_key) ->
      [lev1, lev2] = [file.get(level1_key), file.get(level2_key)]
      if lev1 and lev2
        h[lev1] ||= {}
        h[lev1][lev2] ||= []
        h[lev1][lev2].push(file)

    create_hierarchy = (hash, hierarchy) ->
      for lev1, lev2s of hash
        lev1_obj = {title: lev1, children: [], files: []}
        hierarchy.children.push lev1_obj
        folder_count++
        for lev2, files of lev2s
          lev2_obj = {title: lev2, children: [], files: []}
          lev1_obj.children.push lev2_obj
          folder_count++
          for file in files
            lev2_obj.files.push file
            file_count++

    by_date = {}
    by_location = {}
    selectedFiles = root.get('allChildrenSelectedFiles')
    selectedFiles.forEach (file) ->
      unless file.get('isFotomoo')
        hash_hierarchy(by_date, file, 'year', 'month')
        hash_hierarchy(by_location, file, 'address.country', 'address.city')

    pics_root =
      title: 'Fotomoo Pictures'
      children: [
        {title: "By Date", children: [], files: []}
        {title: "By Location", children: [], files: []}
      ]
      files: []

    create_hierarchy(by_date, pics_root.children[0])
    create_hierarchy(by_location, pics_root.children[1])

    @set('newFolderCount', folder_count)
    @set('processedFolderCount', folder_count)
    @set('newFileCount', file_count)
    @_createTree(pics_root, root)


  _saveDirtyFiles: ->
    @findFolder('root').get('allChildrenSelectedDirtyFiles').forEach (file) =>
      @_linkFile file, ->
        console.log('saved file', file.get('id'), file.get('selected'))
        file.set('dirty', false)
        file.set('selected', false)
        file.set('address.dirty', false) if file.get('address.dirty')

  _createTree: (folder_def, root) ->
    process_folder = (new_folder) =>
      @_createTree(child, new_folder) for child in folder_def.children

      for file in folder_def.files
        file.get('parents').pushObject(id: new_folder.get('id'), isRoot: false)
        file.set('dirty', true)

      @decrementProperty('processedFolderCount')
      @_saveDirtyFiles() if @get('processedFolderCount') < 0


    folder = @get('driveFolderTitleCache').get(folder_def.title)
    if folder
      console.log("folder exists:", folder.get('id'), folder.get('title'))
      process_folder(folder)
    else
      folder_def.parents = [{id: root.get('id')}]
      @_createFolder folder_def, (new_folder_json) =>
        new_folder = FM.Folder.create(new_folder_json)
        new_folder.set('isFotomoo', true)
        console.log('created', new_folder.get('title'), new_folder.get('parents.length'), new_folder.get('parentObj.length'))
        @get('driveFolderObjectCache').set(new_folder_json.id, new_folder)
        root.get('childIds').push(new_folder_json.id)
        process_folder(new_folder)

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
          Ember.run(-> success_callback(result))
        else if result.error.code == 401
          console.log("reathorizing #{method}:", result)
          @_authorize(=> @_execute(method, params, success_callback, error_callback))
        #else if result.error.code == 403
        else
          console.log("ERROR!", result)
          Ember.run( -> error_callback(result)) if error_callback
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
    @_execute('files.list', params, callback, (r) -> alert("Error code:#{r.code}\nPlease reload the page" ))



  _linkFile: (file, callback) ->
    params =
      fileId: file.get('id')
      fields: 'id,title'
      resource:
        parents: file.get('parents')
    if file.get('address') and file.get('address.formattedAddresses') and file.get('address.formattedAddresses').join
      params.resource.indexableText =
        text: file.get('address.formattedAddresses').join(";\n")

    @_queue('files.patch', params, callback)

  _createFolder: (folder, callback) ->
    params =
      fields: 'id,title,parents(id,isRoot)'
      resource:
        title: folder.title
        parents: folder.parents
        mimeType: "application/vnd.google-apps.folder"
    @_queue('files.insert', params, callback)


  execQueue: []
  isQueueRunning: 0
  copiedCount: 0
  fileJustCopied: ''
  queueErrorTryCount: 0

  _queue: (method, params, callback) ->
    console.log('Adding to Q:', method, params, @get('isQueueRunning'), @get('execQueue.length'))
    process = =>
      if @get('execQueue.length')
        [mthod, param, callb] = @get('execQueue').shiftObject()
        @_execute mthod, param, ((result) =>
          console.log('q success', mthod, param, result)
          setTimeout(process, 10)
          @set('fileJustCopied', result.title)
          @incrementProperty('copiedCount')
          @set('queueErrorTryCount', 0)
          callb(result)
        ), ((result) =>
          @incrementProperty('queueErrorTryCount')
          if @get('queueErrorTryCount') > 7
            console.log("exceeded retry count", mthod, param, result)
            @set('execQueue', [])

          if result.error.code == 417
            console.log("got 417, retrying #{@get('queueErrorTryCount')}", mthod, param, result)
            @get('execQueue').pushObject([mthod, param, callb])
            setTimeout(process, 1000)
          else
            console.log("q Unknown Error, retrying #{@get('queueErrorTryCount')}", mthod, param, result)
            @get('execQueue').pushObject([mthod, param, callb])
            setTimeout(process, 5000)
        )
      else
        @decrementProperty('isQueueRunning')
        if @get('isQueueRunning') == 0
          @set('copiedCount', 0)
          console.log('Q: Stopping the queue')

    @get('execQueue').pushObject([method, params, callback])

    if @get('isQueueRunning') < 3
      console.log('starting Q: ', @get('isQueueRunning'))
      @incrementProperty('isQueueRunning')
      setTimeout(process, 100)

  completed: (->
    Math.round(@get('copiedCount') * 100 / (@get('newFileCount') + @get('newFolderCount')))
  ).property('newFileCount', 'newFolderCount',  'copiedCount')



