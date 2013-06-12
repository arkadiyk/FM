window.gapi ||= {}

window.gapi.auth = {
  authorize: (params, callback) ->
    result = {}
    setTimeout ( -> callback(result); console.log('authorized') ), 1000
}

window.gapi.client = {
  load: (api_name, api_version, load_callback) -> setTimeout load_callback, 150
  drive:
    about:
      get: (params)->
        result = FotomooFixtures.about
        execute: (callback) ->
          console.log "calling about.get with ", result
          setTimeout ( ->  callback(result) ), 900
    files:
      list: (params) ->
        folderPtrn = /mimeType\s*=\s*'application\/vnd.google-apps.folder'/
        pageToken = params.pageToken || 'page0'
        result = if params.q.match(folderPtrn) then FotomooFixtures.folders[pageToken] else FotomooFixtures.files[pageToken]
        execute: (callback) ->
          console.log "calling files.list with ", result
          setTimeout ( ->  callback(result) ), 900
      insert: (params) ->
        execute: (callback) ->
          console.log "calling files.insert with ", params.resource
          ret = {id: 'g' + (new Date()).getTime() + Math.floor((Math.random()*100)+1), title: params.resource.title}
          FotomooFixtures.folders.page0.items.push(ret)
          setTimeout ( ->  callback(ret) ), 900
      patch: (params) ->
        execute: (callback) ->
          console.log "calling files.patch with ", params
          ret = {id: params.resource.id, title: params.resource.title}
          setTimeout ( ->  callback(ret) ), 900


}