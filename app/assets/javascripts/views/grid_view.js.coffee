FM.FileGridView = Ember.ListView.extend
  css:
    position: 'relative'
    'overflow-y': 'auto'

  height: 500
  rowHeight: 170
  elementWidth: 240
  width: 960
  itemViewClass: Ember.ListItemView.extend({templateName: "file_grid_item"})

  didInsertElement: ->
    @set('width', Ember.$('.files-panel').width())
    @set('height', Ember.$(window).height() - 41)
    @get('context').set('cols', @get('columnCount'))
    @_super()

  conumnCountObserver: (->
    @get('context').set('cols', @get('columnCount'))
  ).observes('columnCount')

  doubleClick: ->
    @set('width', @get('width') - 30)
