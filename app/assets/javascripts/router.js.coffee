FM.Router.map ->
  @route 'about', {path: '/about'}
  @resource 'setup', ->
    @resource 'files', {path: '/:folder_id'}, ->
      @route 'list'
      @route 'grid'

FM.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'about' # unless FM.drive.get('Fotomoo Folder')

FM.SetupRoute = Ember.Route.extend
  model: -> FM.drive.rootFolder()
  setupController: (controller, model) ->
    controller.set('content', model)
    controller.selectUnprocessedFiles()

FM.SetupIndexRoute = Ember.Route.extend
  model: -> FM.drive.rootFolder()

FM.LoadingRoute = Ember.Route.extend
  enter: ->
  exit: -> Ember.$('#load').remove()


FM.FilesRoute = Ember.Route.extend
  model: (fid) -> FM.Folder.find(fid.folder_id) if fid

