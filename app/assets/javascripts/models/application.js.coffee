FM.ViewMode = Ember.Object.extend
  mode: 'list'
  isList: (->
    @get('mode') == 'list'
  ).property('mode')

FM.viewMode = FM.ViewMode.create({})







