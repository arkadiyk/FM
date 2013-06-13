#= require_self
#= require api-helpers/fotomoo_drive
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
