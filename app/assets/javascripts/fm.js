/*
#= equire ./store
#= equire_tree ./models
#= equire_tree ./controllers
#= equire_tree ./views
#= equire_tree ./helpers
#= equire_tree ./templates
#= equire_tree ./routes
#= equire ./router
#= require_self
*/

App = Ember.Application.create();

App.TreeBranchController = Ember.ObjectController.extend({
});
App.register('controller:treeBranch', App.TreeBranchController, {singleton: false});

App.TreeBranchView = Ember.View.extend({
  tagName: 'ul',
  templateName: 'tree-branch',
  classNames: ['tree-branch']
});

App.TreeNodeController = Ember.ObjectController.extend({
  isExpanded: false,
  toggle: function() {
    this.set('isExpanded', !this.get('isExpanded'));
},
click: function() {
console.log('Clicked: '+this.get('text'));
}
});
App.register('controller:treeNode', App.TreeNodeController, {singleton: false});

App.TreeNodeView = Ember.View.extend({
  tagName: 'li',
  templateName: 'tree-node',
  classNames: ['tree-node']
});


App.set('treeRoot', {
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