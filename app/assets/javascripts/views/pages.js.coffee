class App.Views.Pages extends Backbone.View
  # template: _.template("<div>Hello, <%= name %></div>")
  template: JST['pages/index']

  initialize: ->
    @addActions = new App.Views.AddActions(collection: @collection)
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'add', @renderPage)

  render: =>
    @$el.html(@template())
    @collection.forEach(@renderPage)
    @$el.append(@addActions.render().el)
    this

  renderPage: (page) =>
    view = new App.Views.ShowPage(model: page, tagName: 'li')
    @$('.pages-index').append(view.render().el)

