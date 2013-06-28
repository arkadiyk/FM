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
    #take into account scroller bar width
    old_overflow = document.body.style.overflow
    document.body.style.overflow = "hidden"
    curr_width = Ember.$('.files-panel').width()
    curr_height = Ember.$(window).height() - 41
    document.body.style.overflow = old_overflow

    @set('width', curr_width)
    @set('height', curr_height)
    @get('context').set('cols', @get('columnCount'))

  didInsertElement: ->
    @adjustLayout()
    Ember.$(window).on 'resize', @debouncer((=> @adjustLayout()), 100)
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

