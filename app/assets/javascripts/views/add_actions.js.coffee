class App.Views.AddActions extends Backbone.View
  template: JST['pages/add-actions']

  className: 'add-actions'
  events:
    'click .add-page': 'addPage'

  render: ->
    @$el.html(@template())
    this

  addPage: ->
    @collection.add({})
    false