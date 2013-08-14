window.GapiMock ||= {}
class GapiMock.GapiApi
  constructor: (mock_data) ->
    @mock_data = mock_data || FotomooFixtures

  getAPI: =>
    auth:
      authorize: (params, callback) ->
        result = {}
        setTimeout ( -> callback(result); console.log('authorized') ), 1000
      getToken: -> "==TOKEN=="

    client:
      load: (api_name, api_version, load_callback) -> setTimeout load_callback, 15
      drive:
        about:
          get: (params) =>
            result =
              name: "The Best User Ever"
              user:
                displayName: "The Best User Ever"
                picture: {url: "/assets/photo.jpg"}

            execute: (callback) ->
              console.log "calling about.get with ", result
              setTimeout ( ->  callback(result) ), 10

        files:
          list: (params) =>
            folderPtrn = /mimeType\s*=\s*'application\/vnd.google-apps.folder'/
            if params.q.match /title = 'Fotomoo Settings'/
              result = {items: [id: 'config-ID', downloadUrl: '/ui/fm_config']}
            else
              pageToken = params.pageToken || 'page0'
              result = if params.q.match(folderPtrn) then @mock_data.folders[pageToken] else @mock_data.files[pageToken]

            execute: (callback) ->
              console.log "calling files.list with ", result
              setTimeout ( ->  Ember.run(-> callback(result)) ), 10

          insert: (params) =>
            execute: (callback) =>
              console.log "calling files.insert with ", params.resource
              if Math.floor(Math.random() * 9) < 1
                ret = {error: { code: 417, message: 'Random Fail', errors: [{reason: 'userRateLimitExceeded'}]} }
              else
                ret =
                  id: 'g' + (new Date()).getTime() + Math.floor((Math.random()*100)+1)
                  title: params.resource.title
                  parents: params.resource.parents

                @mock_data.folders.page0.items.push(ret)
              setTimeout ( ->  callback(ret) ), 10

          patch: (params) ->
            execute: (callback) ->
              console.log "calling files.patch with ", params
              if Math.floor(Math.random() * 9) < 1
                ret = {error: { code: 417, message: 'Random Fail', errors: [{reason: 'userRateLimitExceeded'}]} }
              else
                ret = {id: params.fileId, title: 'the title'}
              setTimeout ( ->  callback(ret) ), 10
      request: (params) ->
        execute: (callback) ->
          console.log "calling execute. input:", params
          setTimeout (-> callback({id: "config-ID"})), 10

