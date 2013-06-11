FM.Router.map ->
  @resource 'setup', ->
    @resource 'folder', {path: '/:folder_id'}, ->
      @route 'list'
      @route 'grid'

FM.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'setup' unless FM.drive.get('Fotomoo Folder')

FM.SetupRoute = Ember.Route.extend
  model: -> FM.Folder.find('root')

FM.FolderRoute = Ember.Route.extend
  model: (fid) ->
    FM.Folder.find(fid.folder_id) if fid
  renderTemplate: ->
    @render 'setup/folder',
      into: "application"
      outlet: "folderOutlet"

