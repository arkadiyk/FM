#= require_self
#= require_tree ./api-helpers
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
# equire_tree ./helpers
#= require_tree ./templates
# require_tree ./routes
#= require ./router
# = require ./initialize

window.FM = Ember.Application.create
  LOG_TRANSITIONS: true
  LOG_BINDINGS: true
  DEBUG: true
  LOG_VIEW_LOOKUPS: true
  LOG_ACTIVE_GENERATION: true
