FM.Drive = Ember.Object.extend
  driveFolderObjectCache: Ember.Map.create({})
  driveImageFileObjectCache: Ember.Map.create({})
  driveImageMD5cache: Ember.Map.create({})
  userProfile: Ember.Object.create({})
  activeCallCount: 0
  userProfileLoading: false
  userProfileLoaded: false
  foldersLoading: false
  foldersLoaded: false
  filesLoading: false
  filesLoaded: false
  statusMessage: ''
  statusDetailsMessage: ''

  init: ->
    @gapi = @get('gapi_mock') if @get('gapi_mock')

  apiLoaded: ->
    call_count = 0
    promise = Ember.Deferred.create({})

    if @gapi
      promise.resolve()
    else
      execute = =>
        if window.gapi and window.gapi.auth
          @gapi = window.gapi
          promise.resolve()
        else
          if call_count++ > 10
            promise.reject('Cannot load Google Drive API')
          else
            setTimeout ( => execute() ), 37

      execute()

    promise

  authorize: ->
    execute = (resolve) => @_authorize -> resolve()
    new Ember.RSVP.Promise(execute)

  loadAssets: ->
    Ember.RSVP.all([
      @getUserProfile()
      @loadFolders()
    ]).then => Ember.RSVP.all([
      @loadImageFiles()
      @loadConfiguration()
    ])

  getUserProfile: ->
    @set('statusMessage', 'Authorizing ...')
    @set('userProfileLoading', true)

    promise = Ember.Deferred.create({})
    profile = @get('userProfile')
    callback = (result) =>
      profile.setProperties(result)
      @setProperties(userProfileLoading: false, userProfileLoaded: true)
      promise.resolve()
    @_execute('about.get', {fields: 'name,user'}, callback )
    promise

  loadFolders: () ->
    @set('statusMessage', 'Loading Folders ...a')
    promise = Ember.Deferred.create({})

    process_folders = (folders) =>
      folders.push {id: 'root', title: 'Root Folder', parents: []}

      folder_cache = {}
      folder_cache[f.id] = f for f in folders

      for folder in folders
        folder.parents = [{id: "root", sRoot: true}] unless folder.parents # fixme: shared folders have no parents!
        for parent in folder.parents
          pid = if parent.isRoot then 'root' else parent.id
          folder_cache[pid].childIds ||= []
          folder_cache[pid].childIds.push folder.id

      for folder in folders
        fo = FM.Folder.create(folder)
        @get('driveFolderObjectCache').set(folder.id, fo)
        @set('fotomooFolder', fo) if folder.title == "Fotomoo Pictures"

      mark_children = (ch) ->
        ch.set('isFotomoo', true)
        ch.get('children').forEach (child) -> mark_children(child)
      fotomoo_root = @get('fotomooFolder')
      mark_children(fotomoo_root) if fotomoo_root

      @setProperties(foldersLoading: false, foldersLoaded: true)
      promise.resolve()

    params =
      q: "mimeType = 'application/vnd.google-apps.folder' and 'me' in owners and trashed = false"
      #fields: "items(id,parents(id,isRoot),title),nextPageToken"
      maxResults: 200

    @setProperties(foldersLoading: true, foldersLoaded: false)
    @_loadFiles(params, process_folders)

    promise

  loadImageFiles: ->
    @set('statusMessage', 'Loading Files ...')
    promise = Ember.Deferred.create({})

    process_files = (files) =>
      for file_json in files
        file = FM.File.create(file_json)
        @get('driveImageFileObjectCache').set(file_json.id, file)
        @get('driveImageMD5cache').set(file_json.md5Checksum, file)
        for parent in file_json.parents
          pid = if parent.isRoot then 'root' else parent.id
          folder = @findFolder(pid)
          continue unless folder
          file.set('isFotomoo', true) if folder.get('isFotomoo')
          folder.set('files',[]) unless folder.get('files')
          folder.get('files').addObject(file)

      @setProperties(filesLoading: false, filesLoaded: true)
      promise.resolve()

    params =
      q: "mimeType contains 'image' and 'me' in owners and trashed = false"
      fields: "items(alternateLink,description,explicitlyTrashed,fileExtension,fileSize,id,imageMediaMetadata(cameraMake,cameraModel,date,height,location,rotation,width),md5Checksum,mimeType,openWithLinks,originalFilename,parents(id,isRoot),thumbnailLink,title),nextPageToken"
      maxResults: 200
    @setProperties(filesLoading: true, filesLoaded: false)
    @_loadFiles(params, process_files)
    promise

  findFolder: (fid) -> @get('driveFolderObjectCache').get(fid)
  findImageFile: (fid) -> @get('driveImageFileObjectCache').get(fid)
  rootFolder: ->
    root = @findFolder('root') || @get('root_promise')
    return root if root

    promise = Ember.Deferred.create({})
    @apiLoaded().then =>
      @authorize()
    .then =>
      @loadAssets()
    .then =>
      promise.resolve(@findFolder('root'))
    .then null, (error_message) ->
      console.log("ERROR _1", error_message)
      promise.reject(error_message)

    @set('root_promise', promise)
    promise

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


  unmanageFiles: ->
    dirty_files = []; parents_cache = {}
    @set('newFileCount', @findFolder('root').get('allChildrenManagedFiles.length'))
    @set('newFolderCount', 0)
    @findFolder('root').get('allChildrenManagedFiles').forEach (file) ->
      old_parents = file.get('parents')
      new_parents = []

      old_parents.forEach (parent) ->
        folder = FM.Folder.find(parent.id)
        if folder?.get('isFotomoo')
          parents_cache[parent.id] ||= []
          parents_cache[parent.id].push(file.get('id'))
        else
          new_parents.push(parent)

      if new_parents.length
        file.set('parents', new_parents)
        dirty_files.push file

    for fid, fileids of parents_cache
      folder = @findFolder(fid)
      files = folder.get('files').filter( (f)-> (fileids.indexOf(f.get('id')) < 0) )
      folder.set('files', files)

    dirty_files.forEach (file) =>
      @_linkFile file, ->
        console.log('unmanage file', file.get('id'), file.get('selected'))
        file.setProperties(dirty: false, selected: false, isFotomoo: false)


  _saveDirtyFiles: ->
    @findFolder('root').get('allChildrenSelectedDirtyFiles').forEach (file) =>
      @_linkFile file, ->
        console.log('saved file', file.get('id'), file.get('selected'))
        file.setProperties(dirty: false, selected: false, isFotomoo: true)
        file.set('address.dirty', false) if file.get('address.dirty')

  _createTree: (folder_def, root) ->
    process_folder = (new_folder) =>
      @_createTree(child, new_folder) for child in folder_def.children

      for file in folder_def.files
        file.get('parents').pushObject(id: new_folder.get('id'), isRoot: false)
        file.set('dirty', true)

      @decrementProperty('processedFolderCount')

      if @get('processedFolderCount') < 0
        @saveConfiguration() if FM.config.get('isDirty')
        @_saveDirtyFiles()


    folder = root.get('children').findProperty('title', folder_def.title)
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
        @set('fotomooFolder', new_folder) if new_folder_json.title == "Fotomoo Pictures"
        root.get('childIds').push(new_folder_json.id)
        process_folder(new_folder)

  _authorize: (success_callback) ->
    CLIENT_ID = '865302316429.apps.googleusercontent.com'
    SCOPES = 'https://www.googleapis.com/auth/drive'

    callback = (auth_result) =>
      if auth_result && !auth_result.error
        @set('popupWarningMessage', false)
        success_callback(auth_result)
      else
        @set('popupWarningMessage', true)
        @gapi.auth.authorize( {client_id: CLIENT_ID, scope: SCOPES, immediate: false}, callback)

    @gapi.auth.authorize( {client_id: CLIENT_ID, scope: SCOPES, immediate: true}, callback)

  _execute: (method, params, success_callback, error_callback) ->
    [gapi_area, gapi_call] = method.split('.')
    @incrementProperty('activeCallCount')
    @gapi.client.load 'drive', 'v2', =>
      request = @gapi.client.drive[gapi_area][gapi_call](params)
      request.execute (result) =>
        if not result
          success_callback({items:[]})
        else if not result.error
          success_callback(result)
        else if result.error.code == 401
          console.log("reathorizing #{method}:", result)
          @_authorize(=> @_execute(method, params, success_callback, error_callback))
        #else if result.error.code == 403
        else
          console.log("ERROR!", result)
          error_callback(result) if error_callback
        @decrementProperty('activeCallCount')

  _loadFiles: (params, complete_callback) ->
    files = []
    callback = (result) =>
      files.pushObjects(result.items)
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
          @set('newFileCount', 0)
          @set('newFolderCount', 0)
          console.log('Q: Stopping the queue')

    @get('execQueue').pushObject([method, params, callback])

    if @get('isQueueRunning') < 3
      console.log('starting Q: ', @get('isQueueRunning'))
      @incrementProperty('isQueueRunning')
      setTimeout(process, 150)


  toProcess: (->
    @get('newFileCount') + @get('newFolderCount')
  ).property('newFileCount', 'newFolderCount')

  completed: (->
    Math.round(@get('copiedCount') * 100 / @get('toProcess'))
  ).property('copiedCount', 'toProcess')


  loadConfiguration: ->
    promise = Ember.Deferred.create({})

    fotomoo_root = @get('fotomooFolder.id')
    if fotomoo_root
      download_content = (files_meta) =>
        unless files_meta.length
          promise.resolve()
          return

        FM.config.set('id', files_meta[0].id)
        set_header = (xhr) => xhr.setRequestHeader('Authorization', "Bearer #{@gapi.auth.getToken().access_token}")
        callback = (data) ->
          FM.config.parseResponse(data)
          promise.resolve()

        $.ajax
          url: files_meta[0].downloadUrl
          type: "GET"
          dataType: "json"
          success: callback
          error: (xhr, text_status) ->
            console.log('ERROR: cannot get config', text_status)
            promise.reject(text_status)
          beforeSend: set_header

      params =
        q: "title = 'Fotomoo Settings' and '#{fotomoo_root}' in parents and 'me' in owners and trashed = false"
        fields: "items(id,md5Checksum,downloadUrl)"
      @_loadFiles(params, download_content)
    else
      promise.resolve()


    promise


  saveConfiguration: ->
    fotomoo_root = @get('fotomooFolder.id')

    boundary = '-------314159265358979323846'
    delimiter = "\r\n--#{boundary}\r\n"
    close_delim = "\r\n--#{boundary}--"

    metadata =
      title: "Fotomoo Settings",
      mimeType: "application/json",
      parents: [id: fotomoo_root]


    multipartRequestBody =
      "#{delimiter}Content-Type: application/json\r\n\r\n" +
      JSON.stringify(metadata) +
      "#{delimiter}Content-Type: application/json\r\n\r\n" +
      FM.config.get('json') +
      close_delim

    r_path = '/upload/drive/v2/files'
    r_method = 'POST'

    config_id = FM.config.get('id')
    if config_id
      r_path = r_path + '/' + config_id
      r_method = 'PUT'


    request = @gapi.client.request
      path: r_path
      method: r_method
      params: {uploadType: 'multipart', alt: 'json'}
      headers: { 'Content-Type': 'multipart/mixed; boundary="' + boundary + '"' }
      body: multipartRequestBody

    save_callback = (file) ->
      console.log('SAVED!', file)
      FM.config.set('id', file.id)
      FM.config.set('isDirty', false)

    request.execute(save_callback)


