FM.Router.map ->
  @route 'about'
  @route 'readme'
  @route 'manage'
  @route 'feedback'
  @route 'faq'
  @resource 'setup', ->
    @resource 'files', {path: '/:folder_id'}, ->
      @route 'list'
      @route 'grid'

#FM.IndexRoute = Ember.Route.extend
#  redirect: ->
#    @transitionTo 'about' # unless FM.drive.get('Fotomoo Folder')

FM.ManageRoute = Ember.Route.extend
  model: -> FM.drive.rootFolder()

FM.SetupRoute = Ember.Route.extend
  model: -> FM.drive.rootFolder()
  setupController: (controller, model) ->
    controller.set('content', model)
    controller.selectUnprocessedFiles()

FM.SetupIndexRoute = Ember.Route.extend
  model: -> FM.drive.rootFolder()

FM.LoadingRoute = Ember.Route.extend
  enter: -> Ember.$('#load').modal(keyboard: false, backdrop: 'static')


FM.FilesRoute = Ember.Route.extend
  model: (fid) -> FM.Folder.find(fid.folder_id) if fid

