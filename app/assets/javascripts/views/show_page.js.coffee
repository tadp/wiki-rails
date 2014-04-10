class App.Views.ShowPage extends Backbone.View
  template: JST['pages/show']

  className: 'page'

  initialize: ->
    @listenTo(@model, "invalid", @addError)
    @listenTo(@model, "error", @addError)
    @lastUpdated = new App.Views.LastUpdated(model: @model)

  events:
    'change': 'save'
    'keydown .page-title': 'blurIfEnter'
    'focus .page-title, .page-content': 'beginEditing'
    'blur .page-title, .page-content': 'endEditing'
    'click .destroy-note': 'destroyNote'

  render: ->
    @$el.html(@template(page: @model))
    @lastUpdated.setElement(@$('.normal-footer')).render()
    this

  remove: ->
    @lastUpdated.remove(arguments...)
    super(arguments...)

  save: ->
    @model.set
      title: @$('.page-title').val()
      content: @$('.page-content').val()
    @model.save()
    false

  blurIfEnter: (e) ->
    if e.keyCode == 13
      @$(':input').blur()

  beginEditing: ->
    @$el.addClass('editing')
    @$el.removeClass('error')

  endEditing: ->
    @$el.removeClass('editing')

  destroyNote: ->
    @model.destroy()
    @remove()
    false

  addError: =>
    @$el.addClass('error')