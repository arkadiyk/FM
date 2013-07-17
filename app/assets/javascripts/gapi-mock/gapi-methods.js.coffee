window.gapi ||= {}

window.gapi.auth =
  authorize: (params, callback) ->
    result = {}
    setTimeout ( -> callback(result); console.log('authorized') ), 10

window.gapi.client = {
  load: (api_name, api_version, load_callback) -> setTimeout load_callback, 15
  drive:

    about:
      get: (params)->
        result = FotomooFixtures.about
        execute: (callback) ->
          console.log "calling about.get with ", result
          setTimeout ( ->  callback(result) ), 10

    files:
      list: (params) ->
        folderPtrn = /mimeType\s*=\s*'application\/vnd.google-apps.folder'/
        pageToken = params.pageToken || 'page0'
        result = if params.q.match(folderPtrn) then FotomooFixtures.folders[pageToken] else FotomooFixtures.files[pageToken]
        execute: (callback) ->
          console.log "calling files.list with ", result
          setTimeout ( ->  callback(result) ), 10

      insert: (params) ->
        execute: (callback) ->
          console.log "calling files.insert with ", params.resource
          if Math.floor(Math.random() * 9) < 1
            ret = {error: { code: 417, message: 'Random Fail', errors: [{reason: 'userRateLimitExceeded'}]} }
          else
            ret =
              id: 'g' + (new Date()).getTime() + Math.floor((Math.random()*100)+1)
              title: params.resource.title
              parents: params.resource.parents

            FotomooFixtures.folders.page0.items.push(ret)
          setTimeout ( ->  callback(ret) ), 100

      patch: (params) ->
        execute: (callback) ->
          console.log "calling files.patch with ", params
          if Math.floor(Math.random() * 9) < 1
            ret = {error: { code: 417, message: 'Random Fail', errors: [{reason: 'userRateLimitExceeded'}]} }
          else
            ret = {id: params.fileId, title: 'the title'}
          setTimeout ( ->  callback(ret) ), 100
}
