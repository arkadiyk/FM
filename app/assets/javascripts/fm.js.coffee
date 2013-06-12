#= require_self
# = require api-helpers/fotomoo_drive
# = require ./initialize
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
# equire_tree ./helpers
#= require_tree ./templates
# require_tree ./routes
#= require ./router

window.FM = Ember.Application.create
  LOG_TRANSITIONS: true
  LOG_BINDINGS: true

`
FM.set('treeRoot', {
  text: 'Root',
  children: [
  {
    text: 'People',
    children: [
    {
      text: 'Basketball players',
      children: [
      {
        text: 'Lebron James',
        children: []
      },
      {
        text: 'Kobe Bryant',
        children: []
      }
      ]
    },
    {
      text: 'Astronauts',
      children: [
      {
        text: 'Neil Armstrong',
        children: []
      },
      {
        text: 'Yuri Gagarin',
        children: []
      }
      ]
    }
    ]
  },
  {
    text: 'Fruits',
    children: [
    {
      text: 'Banana',
      children: []
    },
    {
      text: 'Pineapple',
      children: []
    },
    {
      text: 'Orange',
      children: []
    }
    ]
  },
  {
    text: 'Clothes',
    children: [
    {
      text: 'Women',
      children: [
      {
        text: 'Dresses',
        children: []
      },
      {
        text: 'Tops',
        children: []
      }
      ]
    },
    {
      text: 'Men',
      children: [
      {
        text: 'Jeans',
        children: []
      },
      {
        text: 'Shirts',
        children: []
      }
      ]
    }
    ]
  }
  ]
});
`