FM.FileGridView = Ember.ListView.extend
  css:
    position: 'relative'
    'overflow-y': 'auto'

  height: 500
  rowHeight: 170
  elementWidth: 240
  width: 960
  itemViewClass: Ember.ListItemView.extend({templateName: "files/grid-item"})


  adjustLayout: ->
    #todo take into account scroller bar width
    @set('width', Ember.$('.files-panel').width())
    @set('height', Ember.$(window).height() - 41)
    @get('context').set('cols', @get('columnCount'))

  didInsertElement: ->
    @adjustLayout()
    Ember.$(window).on 'resize', @debouncer((=> @adjustLayout()), 200)
    @_super()

  willDestroyElement: -> Ember.$(window).off('resize')

  conumnCountObserver: (->
    @get('context').set('cols', @get('columnCount'))
  ).observes('columnCount')

  debouncer: (func, timeout) ->
    timeoutID = null
    return ->
      clearTimeout( timeoutID )
      timeoutID = setTimeout(func, timeout)

