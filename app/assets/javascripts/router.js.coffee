FM.Router.map ->
  @resource 'setup', ->
    @resource 'files', {path: '/:folder_id'}, ->
      @route 'list'
      @route 'grid'

FM.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'setup' # unless FM.drive.get('Fotomoo Folder')

FM.SetupRoute = Ember.Route.extend
  model: -> FM.Folder.find('root')

FM.FilesRoute = Ember.Route.extend
  model: (fid) ->
    FM.Folder.find(fid.folder_id) if fid
  renderTemplate: ->
    @render 'files',
      into: "application"
      outlet: "files"

